
# comtrader: An R package to access UN Comtrade APIs

<!-- badges: start -->
<!-- badges: end -->

This package simplifies queying data from the UN Comtrade APIs.

## Installation

You can install the development version of comtrader from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("fduranov/comtrader", auth_token = "***********")
```
Contact Federico at <federico.duranovich@mpi.govt> for the authentication token.

## Prerequisites
You need to sign in to [UN Comtrade](https://comtrade.un.org) and get a **key** to be able to connect to the API. 

## Components
- API access key
  - **set_uncomtrade_key** set the API key before calling any other function.
  - **get_uncomtrade_key** retrieve the API key that is currently loaded in your system.

- Get: Model class to extract the data into tibble.
  - **getCTSopi** return tibble containing trade data based on query using SOPI categories.
  - **getUNC** return tibble containing trade data based on query.
  - **getTariffline** return tibble containing tariff line data based on query.
  
- DataAvailability: Model class to extract data availability
  - **getDa** return tibble containing trade dataset availability based on query.
  - **getDaTariffline** return tibble containing tariff line dataset availability based on query.
  
- Metadata: Model class to extract meta data into tibble.
 - **getLiveUpdate** return tibble containing progress on UN Comtrade data release.
 - **getMeatadata** return tibble containing comtrade metadata.
 
- SUV: Model class to extract data on Standard Unit Values (SUV) and their ranges.
 - **getSUV** return tibble containing SUV data based on query.

- Data: tibble containing data to support querying.
 - **omtcodes** contains NZHSC and SOPI codes and categories to assist in querying the data.
 
## Arguments to use in comtrader functions: 

- Selection Criteria
  - typeCode(chr) : Product type. Goods ("C") or Services ("S").
  - freqCode(chr) : The time interval at which observations occur. Annual ("A") or Monthly ("M").
  - clCode(chr) : Indicates the product (IMTS) classification used and which version ("HS", "SITC", "BEC" or "EBOPS").
  
- Query Options    
  - startDate: start date for query ("2020-01-01")
  - endDate: end date for query ("2023-01-01")
  - period(chr or num) : Combination of year and month ("202301") or just year ("2023").
  - reporterCode(chr or num) : The country or geographic area in M49 code to which the measured statistical phenomenon relates (36).
  - cmdCode(chr or num) : Product code in conjunction with classification code ("100190").
  - flowCode(chr) : Trade flow or sub-flow (exports "X", re-exports "RX", imports "M", re-imports "RM", among others).
  - partnerCode(chr or num) : The primary partner country or geographic area for the respective trade flow (36).
  - partner2Code(chr or num) : A secondary partner country or geographic area for the respective trade flow (36).
  - customsCode(chr) : Customs or statistical procedure.
  - motCode(chr) : The mode of transport used when goods enter or leave the economic territory of a country.
  - aggregateBy(chr) : Option for aggregating the query.
  - breakdownMode(chr) : Option to select the classic (trade by partner/product) or plus (extended breakdown) mode. Defaults to "classic".
  - includeDesc(boolean) : Option to include the description or not (TRUE).

## Example

This is a basic example which shows you how to solve a common query:

``` r
library(comtrader)
set_uncomtrade_key(key = "****************")

dairydata <- getCTSopi(freqCode = "A", flowCode = "X", startDate = "2020-01-01", endDate = "2023-05-01", sopiLevel = `Primary Industry Sector`, sopiFilter = "Dairy")

```


