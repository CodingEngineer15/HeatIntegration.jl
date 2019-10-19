#!/usr/local/bin/julia


# need to shift temps by T_MIN
function shiftTemps(data, tmin)
#Functions shifts the temperatures of the streams and also provides the temperature axis.
  t_shift = tmin/2.0
  numStreams = length(data[1,:]) #numste
  println(numStreams)
  shifttemps = zeros(2,numStreams)
  for i=1:numStreams ### Add t_shift to cold stream, deduct t_shift from hot stream 
    if (data[1,i] - data[2,i]) > 0 ### Final temp lower therefore hot stream
      shifttemps[1,i] = data[1,i] - t_shift
      shifttemps[2,i] = data[2,i] - t_shift
      #shifttemps[:,i] = data[1:2,i] .- t_shift
    else  ### Final temp higher therefore cold stream
      shifttemps[1,i] = data[1,i] + t_shift
      shifttemps[2,i] = data[2,i] + t_shift
      #shifttemps[:,i] = data[1:2,i] +- t_shift
    end
  end
  CP = data[3,:]
	# sort(unique(shifttemps[:])): Return a tuple containing the shifted temps in order to provide the temperature intervals
	# shifttemps: Return the data containing shifted temps of the stream
	# Return heat capacities of the stream
  return (sort(unique(shifttemps[:])),shifttemps,CP)

end

function sigmaCP(data,tmin)
## Provides the sum of the CP values for each respective temperature interval.
  tempaxis,ShiftedData,CP = shiftTemps(data,tmin) ####Need to use shifttemps for data
  numStreams = length(data[1,:])
  #temp_interval = zeros(numStreams)
  temp_interval = [tempaxis[i+1] - tempaxis[i] for i=1:length(tempaxis)-1]
  sigma_CP = zeros(length(temp_interval))
  #print(temp_interval) ## so far so good
  for i=1:length(tempaxis)-1
  ##For every interval in the temperature axis...
    sigma_CP[i] = 0.0 # Initial sigma CP to zero for every temperature interval
    ####This is to help form CP stream
    for j=1:numStreams # ... for every stream
	 # This loop checks if the streams temperature overlaps with the temperature interval and updates sigma CP for that stream
      if (ShiftedData[1,j] <= tempaxis[i] && ShiftedData[2,j] <= tempaxis[i]) ||
        (ShiftedData[1,j] >= tempaxis[i+1] && ShiftedData[2,j] >= tempaxis[i+1])##i+1 is the issue 
        ###Edit was in the < -> <=
          continue #### out of range
      else
        if (ShiftedData[1,j] - ShiftedData[2,j]) > 0 ##This makes it a hot stream
          sigma_CP[i] += CP[j]
        else
          sigma_CP[i] -= CP[j] #ShiftedData[3,j]
        end
      end ###### CP stream made
    end
  end
  return sigma_CP
  
end


function ProblemTable(data,tmin)
#This function implements the problem table algorithm
	CP = sigmaCP(data,tmin)
	shiftedData = shiftTemps(data,tmin)
	temp_interval = [shiftedData[1][i+1] - shiftedData[1][i] for i=1:length(shiftedData[1])-1]
	deltaH = CP .* temp_interval
	println(deltaH)
 #Cascade the enthalpies
	cascade = zeros(length(shiftedData[1])) ## This serves as a dump so you don't have to keep making a new array and copying the contents making the code run quicker
	cascade[2:end] = cumsum(reverse(deltaH))
	println("before: ",cascade)
	cascade .-= minimum(cascade)
	println("Hot utility = ",cascade[1])
	println("Cold utility = ",cascade[end])
	index = findmin(cascade)[2] # index of where zero happens, note cascade is all positive now
	reverse!(shiftedData[1]) # Need to reverse the temp axis so it now correlates with cascade
	println("shifted temp where pinch occurs: ", shiftedData[1][index])
	return cascade
end

