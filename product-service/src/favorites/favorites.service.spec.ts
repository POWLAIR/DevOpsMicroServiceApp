import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { FavoritesService } from './favorites.service';
import { Favorite } from './entities/favorite.entity';
import { Repository } from 'typeorm';

describe('FavoritesService', () => {
  let service: FavoritesService;
  let repository: Repository<Favorite>;

  const mockFavorite = {
    id: 1,
    userId: 'user-123',
    productId: 'product-456',
    createdAt: new Date(),
  };

  const mockRepository = {
    find: jest.fn(),
    findOne: jest.fn(),
    save: jest.fn(),
    delete: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        FavoritesService,
        {
          provide: getRepositoryToken(Favorite),
          useValue: mockRepository,
        },
      ],
    }).compile();

    service = module.get<FavoritesService>(FavoritesService);
    repository = module.get<Repository<Favorite>>(getRepositoryToken(Favorite));
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('findByUser', () => {
    it('should return user favorites', async () => {
      mockRepository.find.mockResolvedValue([mockFavorite]);

      const result = await service.findByUser('user-123');

      expect(result).toEqual([mockFavorite]);
      expect(mockRepository.find).toHaveBeenCalledWith({
        where: { userId: 'user-123' },
      });
    });
  });

  describe('addFavorite', () => {
    it('should add a product to favorites', async () => {
      mockRepository.findOne.mockResolvedValue(null);
      mockRepository.save.mockResolvedValue(mockFavorite);

      const result = await service.addFavorite('user-123', 'product-456');

      expect(result).toEqual(mockFavorite);
      expect(mockRepository.save).toHaveBeenCalled();
    });

    it('should throw error if product already in favorites', async () => {
      mockRepository.findOne.mockResolvedValue(mockFavorite);

      await expect(
        service.addFavorite('user-123', 'product-456'),
      ).rejects.toThrow();
    });
  });

  describe('removeFavorite', () => {
    it('should remove a product from favorites', async () => {
      mockRepository.delete.mockResolvedValue({ affected: 1 });

      await service.removeFavorite('user-123', 'product-456');

      expect(mockRepository.delete).toHaveBeenCalledWith({
        userId: 'user-123',
        productId: 'product-456',
      });
    });
  });
});
