import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { FavoritesService } from './favorites.service';
import { Favorite } from './entities/favorite.entity';
import { Product } from '../products/entities/product.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Favorite, Product])],
  providers: [FavoritesService],
  exports: [FavoritesService],
})
export class FavoritesModule {}

