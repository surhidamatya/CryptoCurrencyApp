package com.devebaucha.cryptocurrencyui.presentation.coin_detail

import com.devebaucha.cryptocurrencyui.domain.model.CoinDetail

data class CoinDetailState(
    val isLoading: Boolean = false,
    val coin: CoinDetail? = null,
    val error: String = ""
)
