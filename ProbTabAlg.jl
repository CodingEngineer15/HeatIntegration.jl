#!/usr/local/bin/julia
##########Main issues are in the beginning and end of the loop in ProblemTable algorithm
####test data in order of INITIAL temp, TARGET temp, HEAT_CAPACITY
H1 = [180, 80, 20]
H2  = [130, 40, 40]
C1 = [60, 100, 80]
C2 = [30, 120, 36]
data = hcat(H1,H2,C1,C2)


# need to shift temps by T_MIN
function shiftTemps(data, tmin)
  t_shift = tmin/2.0
  numStreams = length(data[1,:]) #numste
  println(numStreams)
  shifttemps = zeros(2,numStreams)
  for i=1:numStreams
    if (data[1,i] - data[2,i]) > 0
      shifttemps[1,i] = data[1,i] - t_shift
      shifttemps[2,i] = data[2,i] - t_shift
      #shifttemps[:,i] = data[1:2,i] .- t_shift
    else
      shifttemps[1,i] = data[1,i] + t_shift
      shifttemps[2,i] = data[2,i] + t_shift
      #shifttemps[:,i] = data[1:2,i] +- t_shift
    end
  end
  CP = data[3,:]
  return (sort(unique(shifttemps[:])),shifttemps,CP)
end
println(shiftTemps(data,10.0)) #shiftTemps algorithm works

function sigmaCP(data,tmin)
  tempaxis,ShiftedData,CP = shiftTemps(data,tmin) ####Need to use shifttemps for data
  numStreams = length(data[1,:])
  #temp_interval = zeros(numStreams)
  temp_interval = [tempaxis[i+1] - tempaxis[i] for i=1:length(tempaxis)-1]
  sigma_CP = zeros(length(temp_interval))
  #print(temp_interval) ## so far so good
  for i=1:length(tempaxis)-1
  ##for i in eachindex(temp_interval) orginal form
    sigma_CP[i] = 0
    ####This is to help form CP stream
    for j=1:numStreams
      #println("i=",i,"\n","j=",j,"\n")
      if (ShiftedData[1,j] <= tempaxis[i] && ShiftedData[2,j] <= tempaxis[i]) ||
        (ShiftedData[1,j] >= tempaxis[i+1] && ShiftedData[2,j] >= tempaxis[i+1])##i+1 is the issue 
        ###Edit was in the < -> <=
          continue #### out of range
      else
        if (ShiftedData[1,j] - ShiftedData[2,j]) > 0 ##This makes it a hot stream
          sigma_CP[i] += CP[j]
       #   println(data[1,j], "  ,  ", data[2,j], "  CP: ",data[3,j])
      #    println("i=",i,"     ","j=",j,"\n")
        else
          sigma_CP[i] -= CP[j] #ShiftedData[3,j]
    #      println(data[1,j],"     ", data[2,j], "  CP: -",data[3,j])
   #       println("i=",i,"     ","j=",j,"\n")
        end
      end ###### CP stream made
    end
    #println("CP for index ",i,"  ", sigma_CP[i],"-------------------")
  end
  #println("CPs: ",sigma_CP)
  return sigma_CP
  
end

sigmaCP(data,10)

function ProblemTable(data,tmin)
 CP = sigmaCP(data,tmin)
 shiftedData = shiftTemps(data,tmin)
 temp_interval = [shiftedData[1][i+1] - shiftedData[1][i] for i=1:length(shiftedData[1])-1]
 deltaH = CP .* temp_interval
 println(deltaH)
 cascade = zeros(length(shiftedData[1]))
 cascade[2:end] = cumsum(reverse(deltaH))
 println("before: ",cascade)
 cascade .-= minimum(cascade)
 println(cascade)
end

ProblemTable(data,10.0)
########SO far it is correct the whole algorithm, just need to check for when the delta T is less the same as the dTmin
#println(data)
#println(data[3,4])

