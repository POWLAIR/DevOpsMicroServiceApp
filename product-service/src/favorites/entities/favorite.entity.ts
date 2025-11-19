import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, Index } from 'typeorm';

@Entity('favorites')
@Index(['userId', 'productId'], { unique: true })
export class Favorite {
  @PrimaryGeneratedColumn()
  id: number;

  @Column('text')
  @Index()
  userId: string;

  @Column('text')
  @Index()
  productId: string;

  @CreateDateColumn()
  createdAt: Date;
}

