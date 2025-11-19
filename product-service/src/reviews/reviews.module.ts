import { Module, forwardRef } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ReviewsService } from './reviews.service';
import { Review } from './entities/review.entity';
import { Product } from '../products/entities/product.entity';
import { ProductsModule } from '../products/products.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([Review, Product]),
    forwardRef(() => ProductsModule),
  ],
  providers: [ReviewsService],
  exports: [ReviewsService],
})
export class ReviewsModule {}

