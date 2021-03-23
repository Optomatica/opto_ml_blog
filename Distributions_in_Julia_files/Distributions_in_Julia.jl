### A Pluto.jl notebook ###
# v0.12.4

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ b5aea696-7c13-11eb-167e-9d224dbb4e02
# setting things up
begin
	using Plots
	using PlutoUI
	using Distributions
	using CSV
end

# ╔═╡ 50c89d2e-7c11-11eb-09d0-5b0f11cfbb7c
md"This notebook is made to show case the distributions package and how we can use it to start fitting distributions to our data, we use Pluto because it allows us to interactively change hyperparameter values and get a feel for the distributions we create."

# ╔═╡ 5c203ace-7c20-11eb-3232-29f91c67fafc
md"Let's say we want to study the amount of rainfall in Australia. The dataset we will load now contains features to try and help us predict the next day's rainfall. We will try to fit distributions to different features in the data, but first let's look at the values themselves."  

# ╔═╡ c0c3e5fc-7c20-11eb-293a-612f4f78366d
begin
	input_data = CSV.read("weatherAUS.csv")
	first(input_data,10)
end

# ╔═╡ 0c844196-7cd3-11eb-293b-39eebcc1af66
names(input_data)

# ╔═╡ e51a2e52-7c20-11eb-0189-6577e04d27f6
md"The data seems to be saved as strings. Let's process and convert the MinTemp feature then visualize it. We'll first remove any NA cases then convert the other values."

# ╔═╡ c0ea8f6e-7cc4-11eb-1dce-45b9f09f68f0
sum(input_data["MinTemp"].=="NA")/size(input_data,1)

# ╔═╡ d9640476-7cc4-11eb-0ecb-53fa7f582bf5
md""" About 1 percent of the values are "NA", let's skip them so we can convert the data and start modelling"""

# ╔═╡ 549f2e14-7cc4-11eb-03c9-9f2e998ddb20
begin
	filterMinTempNA = input_data["MinTemp"].!="NA"
	min_temp_data = parse.(Float64,input_data["MinTemp"][filterMinTempNA])
	histogram(min_temp_data,label = "MinTemp")
end

# ╔═╡ ebb699fc-7c21-11eb-1c74-4560746a4d54
md"""Let's create different distributions and try to fit them to the data we have. We'll start with modeling the MinTemp, we can select the distribution we want to use from the dropdown below. Also note that to compare our data to the pdf we're generating we should also normalize the histogram we generate.

Distribution type = $(@bind distributionType1 Select(["Normal" => "Gaussian", "Logistic" => "Logistic", "Gamma" => "Gamma", "Laplace" => "Laplace"]))"""

# ╔═╡ 59dc1b74-7c38-11eb-31e6-97ed928b9e20
if distributionType1 == "Normal"
	md""" μ= $(@bind var1 Slider(-20:0.1:40,show_value = true)) 
	
	σ = $(@bind var2 Slider(0.1:0.1:10,show_value = true))
	"""	
elseif distributionType1 == "Gamma"
	md""" α = $(@bind var1 Slider(0.1:0.1:10,show_value = true))
	
	θ = $(@bind var2 Slider(0.1:0.1:10,show_value = true))"""
elseif distributionType1 == "Laplace"
	md""" μ= $(@bind var1 Slider(-20:0.1:40,show_value = true)) 
	
	β = $(@bind var2 Slider(0.1:0.1:10,show_value = true))
	"""	
elseif distributionType1 == "Logistic"
	md""" μ= $(@bind var1 Slider(-20:0.1:40,show_value = true)) 
	
	θ = $(@bind var2 Slider(0.1:0.1:10,show_value = true))
	"""	
end

# ╔═╡ ea219fd2-7c22-11eb-1ce9-e71868c2b6db
begin
	hyperParams = [var1,var2]


	histogram(parse.(Float64,input_data["MinTemp"][filterMinTempNA]),normalize = true,label = "MinTemp")
	plot!([-20:0.1:40],[pdf(eval(Expr(:call,Symbol(distributionType1),hyperParams...)),i) for i in -20:0.1:40],label = "MinTemp pdf")
	xlabel!("Temperature in °C")
	ylabel!("Probability")
end

# ╔═╡ a0e4e76c-7cd0-11eb-0ace-cfee77d684de
md"Playing around with the possible distributions and hyperparameters shows that the most appropriate distribution is the gaussian, with a mean of approximately 12° and a standard deviation of about 6° and we can validate this mathematically:"

# ╔═╡ d74c25c4-7cd3-11eb-1f3b-a900099e5a98
mean(min_temp_data)

# ╔═╡ 0bd57246-7cd4-11eb-3a73-8d0ffdc489de
std(min_temp_data)

# ╔═╡ c337c0f4-7f40-11eb-0450-e1647379867f
md"We can also fit the distribution automatically with the fit_mle function: "

# ╔═╡ f94a787c-7f41-11eb-13f3-7b76e9c44728
fitDistribution = fit_mle(Normal,min_temp_data)

# ╔═╡ 55ad7564-801f-11eb-2a91-75c5f2a980c6
begin
	histogram(parse.(Float64,input_data["MinTemp"][filterMinTempNA]),normalize = true,label = "MinTemp")
	plot!([-20:0.1:40],[pdf(fitDistribution,i) for i in -20:0.1:40],label = "fitted pdf")
	xlabel!("Temperature in °C")
	ylabel!("Probability")
end

# ╔═╡ 1d8f152c-7cd5-11eb-1752-ad2b3c51c663
md"""The functions with an implemented fit function can be seen here:

https://juliastats.org/Distributions.jl/stable/fit/

We can repeat this process for any variable. We'll look at "WindSpeed9am" now:"""

# ╔═╡ 5726eb66-7cd5-11eb-1ec3-89b9c7ecbb65
begin
	filterWindSpeed9amNA = input_data["WindSpeed9am"].!="NA"
	windSpeed9am_data = parse.(Float64,input_data["WindSpeed9am"][filterWindSpeed9amNA])
	histogram(windSpeed9am_data,normalize = true,label = "WindSpeed9am")
end

# ╔═╡ f117cc08-7ce5-11eb-1138-63aebf6c5b74
sort(unique(windSpeed9am_data))

# ╔═╡ 6f32c30c-7f40-11eb-0f4d-6f75eea05246
md"It seems like the data is not continuous, and the speeds have been sampled at different intervals. We will first try to fit a Poisson distribution to it. Note that it is important to convert the incoming input values to Integers before we fit a discrete distribution to them."

# ╔═╡ d8691616-80b5-11eb-0aff-2b9af76f6098
begin
	fitDiscreteDistribution = fit_mle(Poisson,Int.(windSpeed9am_data))
	histogram(windSpeed9am_data,normalize = true,label = "windSpeed9am")
	plot!([0:0.1:120],[pdf(fitDiscreteDistribution,i) for i in 0:0.1:120],label = "fitted pdf")
end

# ╔═╡ d7ce6a56-80b5-11eb-36ad-d1f6ec6ae7c2
md"The fitted Poisson doesn't match the data, this is because of the irregular sampling intervals. Instead of trying to fit a parametric distribution to it, we can create a non parametric distribution of the data if we want to sample from it or use other functions from the distributions package."

# ╔═╡ 668cbfe8-7f31-11eb-294b-e343b444256c
begin
	uniqueWindValues = sort(unique(windSpeed9am_data))
	windSpeedDistribution = DiscreteNonParametric(uniqueWindValues,[sum(windSpeed9am_data.==i)/length(windSpeed9am_data) for i in uniqueWindValues])
end

# ╔═╡ ab874b8e-7f31-11eb-31e6-a3ec6bc93b14
probs(windSpeedDistribution)

# ╔═╡ 49eaa4a8-7f44-11eb-330e-215b4e796261
md"We now have a probability for each unique value of windspeeds. We can also use functions that are normally available for other distributions, such as the cdf:"

# ╔═╡ d85cd804-7f31-11eb-03e2-c92e76f6080d
plot([cdf(windSpeedDistribution,i) for i in 0:100],label = "Wind speed cumulative probability")

# ╔═╡ 9f850a0c-7f44-11eb-0de0-017c3242b944
md"Let's try to model one more variable, the humidity:"

# ╔═╡ 2ad6b464-7f47-11eb-0b29-0df3cde2d7a9
begin
	filterHumidity9amNA = input_data["Humidity9am"].!="NA"
	humidity9am_data = parse.(Float64,input_data["Humidity9am"][filterHumidity9amNA])
	histogram(humidity9am_data,normalize = true,label = "Humidity9am",legend = :topleft)
end

# ╔═╡ 9f391d1a-7f47-11eb-296d-39314ae9782c
md"It looks like this data is a little bit more complicated, fortunetely, we can create a mixture model of any distributions we need, while setting a prior belief of which distribution is more common. Now we'll show how to create a mixture model of two truncated Gaussian distributions to model this data:

μ1 = $(@bind μ1 Slider(0:1:100,show_value = true)) 
---- σ1 = $(@bind σ1 Slider(0.1:0.1:20,show_value = true))

μ2 = $(@bind μ2 Slider(0:1:100,show_value = true))
---- σ2 = $(@bind σ2 Slider(0.1:0.1:20,show_value = true))

prior = $(@bind prior Slider(0.0:0.01:1,show_value = true))	

The prior variable controls the prior belief of distribution 1 vs distribution 2
"

# ╔═╡ 84c78976-7f47-11eb-2a0b-ad01860c8544
humidityDistribution = MixtureModel([
   truncated(Normal(μ1,σ1),-Inf,100),
   truncated(Normal(μ2,σ2),-Inf,100)],[prior,1-prior])

# ╔═╡ f130b5d8-7f56-11eb-0080-59aac056a53c
begin
	begin
		histogram(humidity9am_data,normalize = true,label = "Humidity9am")
		plot!([0:0.1:100],[pdf(humidityDistribution,i) for i in 0:0.1:100],legend = :topleft,label = "Humidity9am pdf")	
	end
end

# ╔═╡ 759d85ee-7f5c-11eb-2cac-8d3e4c1cf7c5
md"This is tougher to fit manually, but a sensible set of parameters might be:

μ1 = 70,

σ1 = 20,

μ2 = 100,

σ2 = 1.5,

prior = 0.97"

# ╔═╡ f8b24866-7fe3-11eb-24c9-37472a7ceecb
md"There are much more distributions and features in the Distributions package. This notebook just serves as a brief introduction to some of its capabilities. If you're interested in more capabilities of the package check the documentation here:

https://juliastats.org/Distributions.jl/stable/ "

# ╔═╡ Cell order:
# ╟─50c89d2e-7c11-11eb-09d0-5b0f11cfbb7c
# ╠═b5aea696-7c13-11eb-167e-9d224dbb4e02
# ╟─5c203ace-7c20-11eb-3232-29f91c67fafc
# ╠═c0c3e5fc-7c20-11eb-293a-612f4f78366d
# ╠═0c844196-7cd3-11eb-293b-39eebcc1af66
# ╟─e51a2e52-7c20-11eb-0189-6577e04d27f6
# ╠═c0ea8f6e-7cc4-11eb-1dce-45b9f09f68f0
# ╟─d9640476-7cc4-11eb-0ecb-53fa7f582bf5
# ╠═549f2e14-7cc4-11eb-03c9-9f2e998ddb20
# ╟─ebb699fc-7c21-11eb-1c74-4560746a4d54
# ╟─59dc1b74-7c38-11eb-31e6-97ed928b9e20
# ╟─ea219fd2-7c22-11eb-1ce9-e71868c2b6db
# ╟─a0e4e76c-7cd0-11eb-0ace-cfee77d684de
# ╠═d74c25c4-7cd3-11eb-1f3b-a900099e5a98
# ╠═0bd57246-7cd4-11eb-3a73-8d0ffdc489de
# ╟─c337c0f4-7f40-11eb-0450-e1647379867f
# ╠═f94a787c-7f41-11eb-13f3-7b76e9c44728
# ╠═55ad7564-801f-11eb-2a91-75c5f2a980c6
# ╟─1d8f152c-7cd5-11eb-1752-ad2b3c51c663
# ╠═5726eb66-7cd5-11eb-1ec3-89b9c7ecbb65
# ╠═f117cc08-7ce5-11eb-1138-63aebf6c5b74
# ╟─6f32c30c-7f40-11eb-0f4d-6f75eea05246
# ╠═d8691616-80b5-11eb-0aff-2b9af76f6098
# ╟─d7ce6a56-80b5-11eb-36ad-d1f6ec6ae7c2
# ╠═668cbfe8-7f31-11eb-294b-e343b444256c
# ╠═ab874b8e-7f31-11eb-31e6-a3ec6bc93b14
# ╟─49eaa4a8-7f44-11eb-330e-215b4e796261
# ╠═d85cd804-7f31-11eb-03e2-c92e76f6080d
# ╟─9f850a0c-7f44-11eb-0de0-017c3242b944
# ╠═2ad6b464-7f47-11eb-0b29-0df3cde2d7a9
# ╟─9f391d1a-7f47-11eb-296d-39314ae9782c
# ╠═84c78976-7f47-11eb-2a0b-ad01860c8544
# ╠═f130b5d8-7f56-11eb-0080-59aac056a53c
# ╟─759d85ee-7f5c-11eb-2cac-8d3e4c1cf7c5
# ╟─f8b24866-7fe3-11eb-24c9-37472a7ceecb
