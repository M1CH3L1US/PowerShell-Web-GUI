import { ComponentFixture, TestBed } from '@angular/core/testing';

import { ShopTableComponent } from './shop-table.component';

describe('ShopTableComponent', () => {
  let component: ShopTableComponent;
  let fixture: ComponentFixture<ShopTableComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ ShopTableComponent ]
    })
    .compileComponents();
  });

  beforeEach(() => {
    fixture = TestBed.createComponent(ShopTableComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
