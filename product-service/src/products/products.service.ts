import { Injectable, NotFoundException, OnModuleInit } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Like } from 'typeorm';
import { Product } from './entities/product.entity';
import { CreateProductDto } from './dto/create-product.dto';
import { UpdateProductDto } from './dto/update-product.dto';
import { UpdateStockDto } from './dto/update-stock.dto';
import { FakeStoreApiService } from '../external-api/fakestore-api.service';
import { v4 as uuidv4 } from 'uuid';

@Injectable()
export class ProductsService implements OnModuleInit {
  constructor(
    @InjectRepository(Product)
    private productRepository: Repository<Product>,
    private fakeStoreApiService: FakeStoreApiService,
  ) {}

  async onModuleInit() {
    await this.seedDatabase();
  }

  async seedDatabase() {
    const existingProducts = await this.productRepository.count();

    if (existingProducts === 0) {
      console.log('Seeding database with FakeStore products...');

      try {
        const products = await this.fakeStoreApiService.getAllProducts();

        for (const product of products) {
          await this.productRepository.save({
            id: uuidv4(),
            name: product.title,
            description: product.description,
            price: product.price,
            category: product.category,
            imageUrl: product.image,
            stock: Math.floor(Math.random() * 100) + 10,
            rating: product.rating?.rate || 0,
            reviewCount: product.rating?.count || 0,
          });
        }

        console.log('Database seeded successfully!');
      } catch (error) {
        console.error('Error seeding database:', error.message);
      }
    }
  }

  async create(createProductDto: CreateProductDto): Promise<Product> {
    const product = this.productRepository.create({
      id: uuidv4(),
      ...createProductDto,
    });
    return this.productRepository.save(product);
  }

  async findAll(): Promise<Product[]> {
    return this.productRepository.find({
      order: { createdAt: 'DESC' },
    });
  }

  async findOne(id: string): Promise<Product> {
    const product = await this.productRepository.findOne({ where: { id } });
    if (!product) {
      throw new NotFoundException(`Product with ID ${id} not found`);
    }
    return product;
  }

  async findByCategory(category: string): Promise<Product[]> {
    return this.productRepository.find({
      where: { category },
      order: { createdAt: 'DESC' },
    });
  }

  async search(query: string): Promise<Product[]> {
    return this.productRepository.find({
      where: [
        { name: Like(`%${query}%`) },
        { description: Like(`%${query}%`) },
      ],
      order: { createdAt: 'DESC' },
    });
  }

  async getCategories(): Promise<string[]> {
    const products = await this.productRepository
      .createQueryBuilder('product')
      .select('DISTINCT product.category', 'category')
      .getRawMany();

    return products.map((p) => p.category);
  }

  async update(id: string, updateProductDto: UpdateProductDto): Promise<Product> {
    const product = await this.findOne(id);
    Object.assign(product, updateProductDto);
    return this.productRepository.save(product);
  }

  async updateStock(id: string, updateStockDto: UpdateStockDto): Promise<Product> {
    const product = await this.findOne(id);
    product.stock = updateStockDto.stock;
    return this.productRepository.save(product);
  }

  async remove(id: string): Promise<void> {
    const product = await this.findOne(id);
    await this.productRepository.remove(product);
  }

  async updateRating(productId: string): Promise<void> {
    const result = await this.productRepository
      .createQueryBuilder()
      .select('AVG(review.rating)', 'avgRating')
      .addSelect('COUNT(review.id)', 'count')
      .from('reviews', 'review')
      .where('review.productId = :productId', { productId })
      .getRawOne();

    const product = await this.findOne(productId);
    product.rating = parseFloat(result.avgRating) || 0;
    product.reviewCount = parseInt(result.count) || 0;
    await this.productRepository.save(product);
  }
}

