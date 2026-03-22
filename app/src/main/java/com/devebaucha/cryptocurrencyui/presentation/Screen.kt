package com.devebaucha.cryptocurrencyui.presentation

sealed class Screen(val route: String) {

    object SplashScreen: Screen("splash_screen")
    object CoinListScreen: Screen("coin_list_screen")
    object CoinDetailScreen: Screen("coin_detail_screen")
}