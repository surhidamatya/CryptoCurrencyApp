package com.devebaucha.cryptocurrencyui.domain.useCase.get_coins

import com.devebaucha.cryptocurrencyui.common.Resource
import com.devebaucha.cryptocurrencyui.data.remote.dto.toCoin
import com.devebaucha.cryptocurrencyui.domain.model.Coin
import com.devebaucha.cryptocurrencyui.domain.repository.CoinRepository
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow
import retrofit2.HttpException
import java.io.IOException
import javax.inject.Inject

class GetCoinsUseCase @Inject constructor(
    private val repository: CoinRepository
) {

    operator fun invoke(): Flow<Resource<List<Coin>>> = flow{
        try {
            emit(Resource.Loading<List<Coin>>())
            val coins = repository.getCoins().map { it.toCoin() }
            emit(Resource.Success<List<Coin>>(coins))
        }catch(e: HttpException){
           emit(Resource.Error<List<Coin>>(e.localizedMessage?: "An unexpected error occurred"))
        }catch (e: IOException){
            emit(Resource.Error<List<Coin>>("Could not connect to server. Please check your connection!!"))
        }
    }
}