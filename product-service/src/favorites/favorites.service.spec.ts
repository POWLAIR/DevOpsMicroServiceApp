import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { NotFoundException, ConflictException } from '@nestjs/common';
import { FavoritesService } from './favorites.service';
import { Favorite } from './entities/favorite.entity';
import { Product } from '../products/entities/product.entity';

describe('FavoritesService', () => {
  let service: FavoritesService;

  const mockFavorite = {
    id: 1,
    userId: 'user-123',
    productId: 'product-456',
    createdAt: new Date(),
  };

  const mockProduct = {
    id: 'product-456',
    title: 'Test Product',
    price: 99.99,
  };

  const mockFavoriteRepository = {
    find: jest.fn(),
    findOne: jest.fn(),
    save: jest.fn(),
    create: jest.fn(),
    remove: jest.fn(),
    delete: jest.fn(),
  };

  const mockProductRepository = {
    findOne: jest.fn(),
    createQueryBuilder: jest.fn(() => ({
      where: jest.fn().mockReturnThis(),
      getMany: jest.fn(),
    })),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        FavoritesService,
        {
          provide: getRepositoryToken(Favorite),
          useValue: mockFavoriteRepository,
        },
        {
          provide: getRepositoryToken(Product),
          useValue: mockProductRepository,
        },
      ],
    }).compile();

    service = module.get<FavoritesService>(FavoritesService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('getUserFavorites', () => {
    it('should return user favorite products', async () => {
      mockFavoriteRepository.find.mockResolvedValue([mockFavorite]);

      const queryBuilder = {
        where: jest.fn().mockReturnThis(),
        getMany: jest.fn().mockResolvedValue([mockProduct]),
      };
      mockProductRepository.createQueryBuilder = jest
        .fn()
        .mockReturnValue(queryBuilder);

      const result = await service.getUserFavorites('user-123');

      expect(result).toEqual([mockProduct]);
      expect(mockFavoriteRepository.find).toHaveBeenCalledWith({
        where: { userId: 'user-123' },
      });
      expect(queryBuilder.where).toHaveBeenCalled();
      expect(queryBuilder.getMany).toHaveBeenCalled();
    });

    it('should return empty array if no favorites', async () => {
      mockFavoriteRepository.find.mockResolvedValue([]);

      const result = await service.getUserFavorites('user-123');

      expect(result).toEqual([]);
    });
  });

  describe('addFavorite', () => {
    it('should add a product to favorites', async () => {
      mockProductRepository.findOne.mockResolvedValue(mockProduct);
      mockFavoriteRepository.findOne.mockResolvedValue(null);
      mockFavoriteRepository.create.mockReturnValue(mockFavorite);
      mockFavoriteRepository.save.mockResolvedValue(mockFavorite);

      const result = await service.addFavorite('user-123', 'product-456');

      expect(result).toEqual(mockFavorite);
      expect(mockProductRepository.findOne).toHaveBeenCalledWith({
        where: { id: 'product-456' },
      });
      expect(mockFavoriteRepository.save).toHaveBeenCalled();
    });

    it('should throw error if product not found', async () => {
      mockProductRepository.findOne.mockResolvedValue(null);

      await expect(
        service.addFavorite('user-123', 'product-456'),
      ).rejects.toThrow(NotFoundException);
    });

    it('should throw error if product already in favorites', async () => {
      mockProductRepository.findOne.mockResolvedValue(mockProduct);
      mockFavoriteRepository.findOne.mockResolvedValue(mockFavorite);

      await expect(
        service.addFavorite('user-123', 'product-456'),
      ).rejects.toThrow(ConflictException);
    });
  });

  describe('removeFavorite', () => {
    it('should remove a product from favorites', async () => {
      mockFavoriteRepository.findOne.mockResolvedValue(mockFavorite);
      mockFavoriteRepository.remove.mockResolvedValue(mockFavorite);

      await service.removeFavorite('user-123', 'product-456');

      expect(mockFavoriteRepository.findOne).toHaveBeenCalledWith({
        where: { userId: 'user-123', productId: 'product-456' },
      });
      expect(mockFavoriteRepository.remove).toHaveBeenCalledWith(mockFavorite);
    });

    it('should throw error if favorite not found', async () => {
      mockFavoriteRepository.findOne.mockResolvedValue(null);

      await expect(
        service.removeFavorite('user-123', 'product-456'),
      ).rejects.toThrow(NotFoundException);
    });
  });
});
