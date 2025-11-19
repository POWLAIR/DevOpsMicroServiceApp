import { Injectable, HttpException, HttpStatus } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import axios from 'axios';

@Injectable()
export class FakeStoreApiService {
  private readonly baseUrl: string;

  constructor(private configService: ConfigService) {
    this.baseUrl = this.configService.get('fakeStoreApi.url');
  }

  async getAllProducts() {
    try {
      const response = await axios.get(`${this.baseUrl}/products`);
      return response.data;
    } catch (error) {
      throw new HttpException(
        'External API error',
        HttpStatus.SERVICE_UNAVAILABLE,
      );
    }
  }

  async getProductById(id: number) {
    try {
      const response = await axios.get(`${this.baseUrl}/products/${id}`);
      return response.data;
    } catch (error) {
      throw new HttpException(
        'Product not found in external API',
        HttpStatus.NOT_FOUND,
      );
    }
  }

  async getCategories() {
    try {
      const response = await axios.get(`${this.baseUrl}/products/categories`);
      return response.data;
    } catch (error) {
      throw new HttpException(
        'External API error',
        HttpStatus.SERVICE_UNAVAILABLE,
      );
    }
  }

  async getProductsByCategory(category: string) {
    try {
      const response = await axios.get(
        `${this.baseUrl}/products/category/${category}`,
      );
      return response.data;
    } catch (error) {
      throw new HttpException('Category not found', HttpStatus.NOT_FOUND);
    }
  }
}

