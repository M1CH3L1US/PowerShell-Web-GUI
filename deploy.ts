import { existsSync } from 'fs';
import { copyFile, mkdir, readdir } from 'fs/promises';
import { join } from 'path';

const bootstrap = async () => {
  const angularProjectBuildPath = join(__dirname, "web", "dist", "web");
  const corePath = join(__dirname, "core");
  const powershellModulePath = join(corePath, "lib", "promt.psm1");
  const powershellEntryPointPath = join(corePath, "index.ps1");

  const buildPath = join(__dirname, "build");
  const buildLibPath = join(buildPath, "lib");
  const buildPublicPath = join(buildPath, "public");

  console.log("Deploying application");
  console.log("Checking files");

  if (!existsSync(buildPath)) await mkdir(buildPath);
  if (!existsSync(buildLibPath)) await mkdir(buildLibPath);
  if (!existsSync(buildPublicPath)) await mkdir(buildPublicPath);

  if (!existsSync(angularProjectBuildPath))
    throw "Build the angular project first at ./web/dist/web";
  if (!existsSync(powershellModulePath))
    throw "The promt PowerShell module is missing at ./core/lib/promt.psm1";
  if (!existsSync(powershellEntryPointPath))
    throw "The PowerShell entry point file is missing at ./core/index.ps1";

  console.log("[OK]");
  console.log("Reading angular build files");

  const angularBuildFiles = await readdir(angularProjectBuildPath);
  const powershellFiles = await readdir(corePath);
  const powershellLibFiles = await readdir(join(corePath, "lib"));

  console.log("Copying public files");

  await Promise.all(
    angularBuildFiles.map((file) =>
      copyFile(join(angularProjectBuildPath, file), join(buildPublicPath, file))
    )
  );

  console.log("[OK]");
  console.log("Copying PowerShell core files");

  await Promise.all(
    powershellFiles.map((file) =>
      copyFile(join(corePath, file), join(buildPath, file))
    )
  );

  await Promise.all(
    powershellLibFiles.map((file) =>
      copyFile(join(powershellModulePath, file), join(buildLibPath, file))
    )
  );

  console.log("[OK]");
  console.log("Deploy successful");
};

bootstrap().catch((err) => console.error(err));
