import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, UpdateDateColumn, Index } from 'typeorm';

@Entity('reviews')
@Index(['userId', 'productId'], { unique: true })
export class Review {
  @PrimaryGeneratedColumn()
  id: number;

  @Column('text')
  @Index()
  userId: string;

  @Column('text')
  @Index()
  productId: string;

  @Column('integer')
  rating: number;

  @Column('text', { nullable: true })
  comment: string;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}

