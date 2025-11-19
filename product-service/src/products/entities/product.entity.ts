import { Entity, Column, PrimaryColumn, CreateDateColumn, UpdateDateColumn, Index } from 'typeorm';

@Entity('products')
export class Product {
  @PrimaryColumn('text')
  id: string;

  @Column('text')
  @Index()
  name: string;

  @Column('text', { nullable: true })
  description: string;

  @Column('real')
  price: number;

  @Column('text')
  @Index()
  category: string;

  @Column('text', { nullable: true })
  imageUrl: string;

  @Column('integer', { default: 0 })
  stock: number;

  @Column('real', { default: 0 })
  rating: number;

  @Column('integer', { default: 0 })
  reviewCount: number;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}

