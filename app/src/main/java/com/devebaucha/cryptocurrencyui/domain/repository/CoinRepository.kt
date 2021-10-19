package com.devebaucha.cryptocurrencyui.domain.repository

import com.devebaucha.cryptocurrencyui.data.remote.dto.CoinDetailDto
import com.devebaucha.cryptocurrencyui.data.remote.dto.CoinDto

interface CoinRepository {

    suspend fun getCoins(): List<CoinDto>

    suspend fun getCoinById (coinId: String): CoinDetailDto
}