"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __generator = (this && this.__generator) || function (thisArg, body) {
    var _ = { label: 0, sent: function() { if (t[0] & 1) throw t[1]; return t[1]; }, trys: [], ops: [] }, f, y, t, g;
    return g = { next: verb(0), "throw": verb(1), "return": verb(2) }, typeof Symbol === "function" && (g[Symbol.iterator] = function() { return this; }), g;
    function verb(n) { return function (v) { return step([n, v]); }; }
    function step(op) {
        if (f) throw new TypeError("Generator is already executing.");
        while (_) try {
            if (f = 1, y && (t = op[0] & 2 ? y["return"] : op[0] ? y["throw"] || ((t = y["return"]) && t.call(y), 0) : y.next) && !(t = t.call(y, op[1])).done) return t;
            if (y = 0, t) op = [op[0] & 2, t.value];
            switch (op[0]) {
                case 0: case 1: t = op; break;
                case 4: _.label++; return { value: op[1], done: false };
                case 5: _.label++; y = op[1]; op = [0]; continue;
                case 7: op = _.ops.pop(); _.trys.pop(); continue;
                default:
                    if (!(t = _.trys, t = t.length > 0 && t[t.length - 1]) && (op[0] === 6 || op[0] === 2)) { _ = 0; continue; }
                    if (op[0] === 3 && (!t || (op[1] > t[0] && op[1] < t[3]))) { _.label = op[1]; break; }
                    if (op[0] === 6 && _.label < t[1]) { _.label = t[1]; t = op; break; }
                    if (t && _.label < t[2]) { _.label = t[2]; _.ops.push(op); break; }
                    if (t[2]) _.ops.pop();
                    _.trys.pop(); continue;
            }
            op = body.call(thisArg, _);
        } catch (e) { op = [6, e]; y = 0; } finally { f = t = 0; }
        if (op[0] & 5) throw op[1]; return { value: op[0] ? op[1] : void 0, done: true };
    }
};
exports.__esModule = true;
var fs_1 = require("fs");
var promises_1 = require("fs/promises");
var path_1 = require("path");
var bootstrap = function () { return __awaiter(void 0, void 0, void 0, function () {
    var angularProjectBuildPath, powershellModulePath, powershellEntryPointPath, buildPath, buildLibPath, buildPublicPath, angularBuildFiles;
    return __generator(this, function (_a) {
        switch (_a.label) {
            case 0:
                angularProjectBuildPath = path_1.join(__dirname, "web", "dist", "web");
                powershellModulePath = path_1.join(__dirname, "core", "lib", "promt.psm1");
                powershellEntryPointPath = path_1.join(__dirname, "core", "index.ps1");
                buildPath = path_1.join(__dirname, "build");
                buildLibPath = path_1.join(buildPath, "lib");
                buildPublicPath = path_1.join(buildPath, "public");
                console.log("Deploying application");
                console.log("Checking files");
                if (!!fs_1.existsSync(buildPath)) return [3 /*break*/, 2];
                return [4 /*yield*/, promises_1.mkdir(buildPath)];
            case 1:
                _a.sent();
                _a.label = 2;
            case 2:
                if (!!fs_1.existsSync(buildLibPath)) return [3 /*break*/, 4];
                return [4 /*yield*/, promises_1.mkdir(buildLibPath)];
            case 3:
                _a.sent();
                _a.label = 4;
            case 4:
                if (!!fs_1.existsSync(buildPublicPath)) return [3 /*break*/, 6];
                return [4 /*yield*/, promises_1.mkdir(buildPublicPath)];
            case 5:
                _a.sent();
                _a.label = 6;
            case 6:
                if (!fs_1.existsSync(angularProjectBuildPath))
                    throw "Build the angular project first at ./web/dist/web";
                if (!fs_1.existsSync(powershellModulePath))
                    throw "The promt PowerShell module is missing at ./core/lib/promt.psm1";
                if (!fs_1.existsSync(powershellEntryPointPath))
                    throw "The PowerShell entry point file is missing at ./core/index.ps1";
                console.log("[OK]");
                console.log("Reading angular build files");
                return [4 /*yield*/, promises_1.readdir(angularProjectBuildPath)];
            case 7:
                angularBuildFiles = _a.sent();
                console.log("Copying public files");
                return [4 /*yield*/, Promise.all(angularBuildFiles.map(function (file) {
                        return promises_1.copyFile(path_1.join(angularProjectBuildPath, file), path_1.join(buildPublicPath, file));
                    }))];
            case 8:
                _a.sent();
                console.log("[OK]");
                console.log("Copying PowerShell core files");
                return [4 /*yield*/, promises_1.copyFile(powershellEntryPointPath, path_1.join(buildPath, "index.ps1"))];
            case 9:
                _a.sent();
                return [4 /*yield*/, promises_1.copyFile(powershellModulePath, path_1.join(buildLibPath, "promt.psm1"))];
            case 10:
                _a.sent();
                console.log("[OK]");
                console.log("Deploy successful");
                return [2 /*return*/];
        }
    });
}); };
bootstrap()["catch"](function (err) { return console.error(err); });
