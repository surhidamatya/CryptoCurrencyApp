package com.devebaucha.cryptocurrencyui.presentation

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.material.MaterialTheme
import androidx.compose.material.Surface
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.devebaucha.cryptocurrencyui.presentation.coin_detail.components.CoinDetailScreen
import com.devebaucha.cryptocurrencyui.presentation.coin_list.CoinListScreen
import com.devebaucha.cryptocurrencyui.presentation.coin_list.components.CoinListItem
import com.devebaucha.cryptocurrencyui.presentation.ui.theme.CryptocurrencyUI
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            CryptocurrencyUI {
                Surface(color = MaterialTheme.colors.background) {
                    val navController = rememberNavController()
                    NavHost(
                        navController = navController,
                        startDestination = Screen.SplashScreen.route
                    )
                    {
                        composable(route = Screen.SplashScreen.route){
                            SplashScreen(navController)
                        }
                        composable(route = Screen.CoinListScreen.route){
                           CoinListScreen(navController)
                        }
                        composable(route = Screen.CoinDetailScreen.route + "/{coinId}"){
                            CoinDetailScreen()
                        }

                    }
                }
            }
        }
    }
}