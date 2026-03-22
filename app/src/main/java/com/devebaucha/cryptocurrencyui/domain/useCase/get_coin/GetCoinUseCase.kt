package com.devebaucha.cryptocurrencyui.domain.useCase.get_coin

import com.devebaucha.cryptocurrencyui.common.Resource
import com.devebaucha.cryptocurrencyui.data.remote.dto.toCoin
import com.devebaucha.cryptocurrencyui.data.remote.dto.toCoinDetail
import com.devebaucha.cryptocurrencyui.domain.model.Coin
import com.devebaucha.cryptocurrencyui.domain.model.CoinDetail
import com.devebaucha.cryptocurrencyui.domain.repository.CoinRepository
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow
import retrofit2.HttpException
import java.io.IOException
import javax.inject.Inject

class GetCoinUseCase @Inject constructor(
    private val repository: CoinRepository
) {

    operator fun invoke(coinId: String): Flow<Resource<CoinDetail>> = flow{
        try {
            emit(Resource.Loading<CoinDetail>())
            val coin = repository.getCoinById(coinId).toCoinDetail()
            emit(Resource.Success<CoinDetail>(coin))
        }catch(e: HttpException){
           emit(Resource.Error<CoinDetail>(e.localizedMessage?: "An unexpected error occurred"))
        }catch (e: IOException){
            emit(Resource.Error<CoinDetail>("Could not connect to server. Please check your connection!!"))
        }
    }
}