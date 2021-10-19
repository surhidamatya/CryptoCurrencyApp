package com.devebaucha.cryptocurrencyui.data.repository

import com.devebaucha.cryptocurrencyui.data.remote.CoinPaprikaApi
import com.devebaucha.cryptocurrencyui.data.remote.dto.CoinDetailDto
import com.devebaucha.cryptocurrencyui.data.remote.dto.CoinDto
import com.devebaucha.cryptocurrencyui.domain.repository.CoinRepository
import javax.inject.Inject

class CoinRepositoryImpl @Inject constructor(
    private val api: CoinPaprikaApi
): CoinRepository{
    override suspend fun getCoins(): List<CoinDto> {
        return api.getCoins()
    }

    override suspend fun getCoinById(coinId: String): CoinDetailDto {
        return api.getCoinById(coinId)
    }
}