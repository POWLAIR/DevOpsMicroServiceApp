import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Patch,
  Body,
  Param,
  Query,
  UseGuards,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { ProductsService } from './products.service';
import { FavoritesService } from '../favorites/favorites.service';
import { ReviewsService } from '../reviews/reviews.service';
import { CreateProductDto } from './dto/create-product.dto';
import { UpdateProductDto } from './dto/update-product.dto';
import { UpdateStockDto } from './dto/update-stock.dto';
import { CreateReviewDto } from '../reviews/dto/create-review.dto';
import { UpdateReviewDto } from '../reviews/dto/update-review.dto';

@Controller()
export class ProductsController {
  constructor(
    private readonly productsService: ProductsService,
    private readonly favoritesService: FavoritesService,
    private readonly reviewsService: ReviewsService,
  ) {}

  // ===== ENDPOINTS PUBLICS (Produits) =====

  @Get('products')
  findAllProducts() {
    return this.productsService.findAll();
  }

  @Get('products/search')
  searchProducts(@Query('q') query: string) {
    return this.productsService.search(query);
  }

  @Get('products/:id')
  findOneProduct(@Param('id') id: string) {
    return this.productsService.findOne(id);
  }

  @Get('categories')
  getCategories() {
    return this.productsService.getCategories();
  }

  @Get('products/category/:name')
  findByCategory(@Param('name') category: string) {
    return this.productsService.findByCategory(category);
  }

  @Get('products/:id/reviews')
  getProductReviews(@Param('id') productId: string) {
    return this.reviewsService.findByProduct(productId);
  }

  // ===== ENDPOINTS PROTÉGÉS (CRUD Produits - Admin) =====

  @Post('products')
  @UseGuards(JwtAuthGuard)
  createProduct(@Body() createProductDto: CreateProductDto) {
    return this.productsService.create(createProductDto);
  }

  @Put('products/:id')
  @UseGuards(JwtAuthGuard)
  updateProduct(
    @Param('id') id: string,
    @Body() updateProductDto: UpdateProductDto,
  ) {
    return this.productsService.update(id, updateProductDto);
  }

  @Patch('products/:id/stock')
  @UseGuards(JwtAuthGuard)
  updateStock(@Param('id') id: string, @Body() updateStockDto: UpdateStockDto) {
    return this.productsService.updateStock(id, updateStockDto);
  }

  @Delete('products/:id')
  @UseGuards(JwtAuthGuard)
  @HttpCode(HttpStatus.OK)
  removeProduct(@Param('id') id: string) {
    return this.productsService.remove(id);
  }

  // ===== ENDPOINTS PROTÉGÉS (Favoris) =====

  @Get('favorites')
  @UseGuards(JwtAuthGuard)
  getUserFavorites(@CurrentUser() user: any) {
    return this.favoritesService.getUserFavorites(user.userId);
  }

  @Post('products/:id/favorite')
  @UseGuards(JwtAuthGuard)
  @HttpCode(HttpStatus.CREATED)
  addFavorite(@Param('id') productId: string, @CurrentUser() user: any) {
    return this.favoritesService.addFavorite(user.userId, productId);
  }

  @Delete('products/:id/favorite')
  @UseGuards(JwtAuthGuard)
  @HttpCode(HttpStatus.OK)
  removeFavorite(@Param('id') productId: string, @CurrentUser() user: any) {
    return this.favoritesService.removeFavorite(user.userId, productId);
  }

  @Get('products/:id/is-favorite')
  @UseGuards(JwtAuthGuard)
  isFavorite(@Param('id') productId: string, @CurrentUser() user: any) {
    return this.favoritesService.isFavorite(user.userId, productId);
  }

  // ===== ENDPOINTS PROTÉGÉS (Avis) =====

  @Post('products/:id/review')
  @UseGuards(JwtAuthGuard)
  @HttpCode(HttpStatus.CREATED)
  createReview(
    @Param('id') productId: string,
    @Body() createReviewDto: CreateReviewDto,
    @CurrentUser() user: any,
  ) {
    return this.reviewsService.create(user.userId, productId, createReviewDto);
  }

  @Put('reviews/:id')
  @UseGuards(JwtAuthGuard)
  updateReview(
    @Param('id') id: string,
    @Body() updateReviewDto: UpdateReviewDto,
    @CurrentUser() user: any,
  ) {
    return this.reviewsService.update(parseInt(id), user.userId, updateReviewDto);
  }

  @Delete('reviews/:id')
  @UseGuards(JwtAuthGuard)
  @HttpCode(HttpStatus.OK)
  removeReview(@Param('id') id: string, @CurrentUser() user: any) {
    return this.reviewsService.remove(parseInt(id), user.userId);
  }
}

