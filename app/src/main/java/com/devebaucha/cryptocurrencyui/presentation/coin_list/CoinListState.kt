package com.devebaucha.cryptocurrencyui.presentation.coin_list

import com.devebaucha.cryptocurrencyui.domain.model.Coin

data class CoinListState(
    val isLoading: Boolean = false,
    val coins: List<Coin> = emptyList(),
    val error: String = ""
)
