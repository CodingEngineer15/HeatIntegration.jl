
# HeatIntegration.jl
A set of functions to help in process heat integration 
Please note that the code is still going through testing and optimisation to make it more user friendly and is likely to break with future update
# The data of the streams which should be in this format [supply temperature, target temperature, Heat capacity flowrate]

#Open up the julia shell and type in the following and provide execution permissions to files ending in .jl

H1 = [180, 80, 20]

H2  = [130, 40, 40]

C1 = [60, 100, 80]

C2 = [30, 120, 36]

data = hcat(H1,H2,C1,C2) # It is recommended that the data should be in a 3xn matrix

#Change to the HeatIntegration.jl directory

#Then add permissions to the programmes ending in .jl

include("PropTabAlg.jl") #Occasionally throws an error for some reason. Make sure permissions are provided then execute this line again

Main.HeatIntegration.ProblemTable(data,10.0) # where 10.0 is the minimum temperature difference. Note that the temperature difference must be a float
