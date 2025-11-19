import { Module } from '@nestjs/common';
import { FakeStoreApiService } from './fakestore-api.service';

@Module({
  providers: [FakeStoreApiService],
  exports: [FakeStoreApiService],
})
export class ExternalApiModule {}

