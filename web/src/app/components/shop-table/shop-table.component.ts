import { SelectionModel } from '@angular/cdk/collections';
import { AfterViewInit, ChangeDetectorRef, Component, Input, OnChanges, OnInit, ViewChild } from '@angular/core';
import { MatPaginator } from '@angular/material/paginator';
import { MatTableDataSource } from '@angular/material/table';
import { IShop } from 'src/app/interfaces';

@Component({
  selector: 'shop-table',
  templateUrl: './shop-table.component.html',
  styleUrls: ['./shop-table.component.scss'],
})
export class ShopTableComponent implements OnInit, AfterViewInit, OnChanges {
  @Input() shops: IShop[];

  @ViewChild(MatPaginator) paginator: MatPaginator;
  selection = new SelectionModel<IShop>(true, []);
  dataSource: MatTableDataSource<IShop>;
  displayedColumns = ['selected', 'shopnumber', 'name', 'rayon', 'address'];

  constructor(private changeDetectorRefs: ChangeDetectorRef) {}

  ngOnInit(): void {
    this.dataSource = new MatTableDataSource<IShop>(this.shops);
  }

  ngAfterViewInit() {
    this.dataSource.paginator = this.paginator;
  }

  updateData(shops: IShop[]) {
    if (!this.dataSource) return;

    this.dataSource.data = shops;
    this.changeDetectorRefs.detectChanges();
  }

  getCurrentShopData() {
    return this.dataSource.data;
  }

  ngOnChanges() {
    this.updateData(this.shops);
  }

  handleDelete() {
    const shops = this.shops.filter((shop) => !this.selection.isSelected(shop));
    this.updateData(shops);
  }
}
