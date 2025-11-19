import { Injectable, NotFoundException, ConflictException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Favorite } from './entities/favorite.entity';
import { Product } from '../products/entities/product.entity';

@Injectable()
export class FavoritesService {
  constructor(
    @InjectRepository(Favorite)
    private favoriteRepository: Repository<Favorite>,
    @InjectRepository(Product)
    private productRepository: Repository<Product>,
  ) {}

  async addFavorite(userId: string, productId: string): Promise<Favorite> {
    const product = await this.productRepository.findOne({
      where: { id: productId },
    });

    if (!product) {
      throw new NotFoundException(`Product with ID ${productId} not found`);
    }

    const existingFavorite = await this.favoriteRepository.findOne({
      where: { userId, productId },
    });

    if (existingFavorite) {
      throw new ConflictException('Product already in favorites');
    }

    const favorite = this.favoriteRepository.create({ userId, productId });
    return this.favoriteRepository.save(favorite);
  }

  async removeFavorite(userId: string, productId: string): Promise<void> {
    const favorite = await this.favoriteRepository.findOne({
      where: { userId, productId },
    });

    if (!favorite) {
      throw new NotFoundException('Favorite not found');
    }

    await this.favoriteRepository.remove(favorite);
  }

  async getUserFavorites(userId: string): Promise<Product[]> {
    const favorites = await this.favoriteRepository.find({
      where: { userId },
    });

    const productIds = favorites.map((f) => f.productId);

    if (productIds.length === 0) {
      return [];
    }

    return this.productRepository
      .createQueryBuilder('product')
      .where('product.id IN (:...ids)', { ids: productIds })
      .getMany();
  }

  async isFavorite(userId: string, productId: string): Promise<boolean> {
    const favorite = await this.favoriteRepository.findOne({
      where: { userId, productId },
    });
    return !!favorite;
  }
}

