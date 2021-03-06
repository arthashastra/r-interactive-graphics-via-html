
# Add blank script lines. This function has side effects:
appendBlankLine <- function(numLine = 1) {
  
  .RIGHT$scriptArray <- c(.RIGHT$scriptArray, rep("", numLine))
  
} # function appendBlankLine

prependBlankLine <- function(numLine = 1) {
  
  .RIGHT$scriptArray <- c(rep("", numLine), .RIGHT$scriptArray)
  
} # function prependBlankLine

# Save data.frame objects:

prepareData <- function(dataList, dir = ".") {
  
  # Array to save all data (data array, discrete data level)
  dataScript <- c()
  
  # CHECK (junghoon): what happens if no names are given?
  nameArray <- names(dataList)
  
  # lapply will not work since it does not preserve the names of the list entries
  numData <- length(nameArray)  

  # Save data array using json form
  for (iData in 1:numData) {
    
    tempData <- as.list(dataList[[nameArray[iData]]])
    dataArr <- lapply(tempData, function(x) if (is.factor(x)) list(level = levels(x), index = as.numeric(x) - 1) else x)
    
    mainArr <- rjson::toJSON(dataArr)
    dataScript <- c(dataScript, paste0("var ", nameArray[iData], " = ", mainArr))
    
  } # for
  
  tempDir <- file.path(dir, "www")
  
  if (!file.exists(tempDir)) {
    dir.create(tempDir)
  } # if
  
  # Write dataScript to "data.js" file
  writeLines(as.character(dataScript), con=file.path(dir, "www", "data.js"))
  
} # function prepareDataE

# Add JavaScript expressions to load data. This function has side effects:
loadData <- function(nameArray = NULL) {
  
  numData <- length(nameArray)
  
  if (!is.null(nameArray)) {
    
    # Data objects should be loaded before any plotting:
    for(iData in 1:numData) {
      .RIGHT$structArray <- append(.RIGHT$structArray,
                                   paste0("var ",nameArray[iData], 
                                          " = createMainStructureE(", nameArray[iData], ");")) 
    } # for
  } # if
  
  invisible()
  
} # function loadData

# This function has side effects:
addDrawTrigger <- function(nameArray = NULL) {
  
  if(is.null(nameArray)) {
    return(NULL)
  } # if
  
  .RIGHT$scriptArray <- append(.RIGHT$scriptArray,
                               paste0(nameArray, ".draw();"))
}

# This function has side effects:
addEventTrigger <- function(numAxis = NULL) {
  
  if (is.null(numAxis) || numAxis == 0) {
    return(NULL)
  } # if
  
  .RIGHT$scriptArray <- append(.RIGHT$scriptArray, 
                               paste0("var AllAxisObjArr = [", 
                                      paste0(paste0("axis", 1:numAxis), collapse = ", "),
                                      "]; eventTrigger(AllAxisObjArr);"))
  
} # function addEventTrigger

# Create div block:
createDiv <- function(divArray = NULL, flag = FALSE) {
   
  if (is.null(divArray)) {
    return(NULL)
  } # if 
  
  tempArray <- '<div id="content">'
  tempArray2 <- c()
  divIndex <- 1
  divId <- c()
  
  if(flag) {
    
    for(iData in 1:.RIGHT$numAxis) {
      
      tempIndex <- 0      
      divId <- append(divId, "")
      for(i in 1:length(.RIGHT$offIndex)) {
        
        if(iData == .RIGHT$offIndex[i]) {
          
          divId[iData] <- paste0(divId[iData], 
                                 '<div id="', .RIGHT$offNameArr[divIndex], '" class="right-output">\n')
          divIndex <- divIndex + 1
          tempIndex <- tempIndex + 1
          
        } # if
        
      } # for
            
      if(tempIndex == 0) {
        
        divId[iData] <- paste0(divId[iData], 
                               '<div id="content', iData, '" class="right-output">\n')
        tempIndex <- tempIndex + 1
        
      } # if
      
      tempArray <- append(tempArray, paste0(divId[iData], "  ", divArray[iData]))
    
    } # for
    
    for(iData in 2:length(tempArray)) {
      tempArray[iData] <- paste0(tempArray[iData], "</div>")
    }
  
  } else {
    
    for(iData in 1:length(divArray)) {
      tempArray <- append(tempArray, paste0('<div id="content', iData, '" class="right-output">\n',
                          divArray[iData], "</div>\n"))
    } # for
    
  } # if
  
  if(!is.null(.RIGHT$ncolGraph)) {
    
    tempIndex <- c()
    
    for(count in .RIGHT$ncolGraph) {
      if(count == 1) {
        tempIndex <- c(tempIndex, 12)
      } else if(count == 2) {
        tempIndex <- c(tempIndex, 6, 6)
      } else if(count == 3) {
        tempIndex <- c(tempIndex, 4, 4, 4)
      } else if(count == 4) {
        tempIndex <- c(tempIndex, 3, 3, 3, 3)
      } # if
    } # for
    
    for(iData in 2:length(tempArray)) {
      tempArray[iData] <- paste0('<div class="col-md-', tempIndex[iData-1], '">\n', tempArray[iData], "</div>\n")
    } # for
    
    iData <- 2
    
    for(count in .RIGHT$ncolGraph) {
      tempArray[iData] <- paste0('<div class="row">\n', tempArray[iData])
      iData <- iData + count - 1
      tempArray[iData] <- paste0(tempArray[iData], "</div>\n")
      iData <- iData + 1
    } # for
    
  } # if
  
  if(.RIGHT$numSearch > 0) {
        
    tempArray2 <- paste0('<div class="navbar navbar-fixed-top" role="navigation">\n',
                         '<div class="navbar-header">\n',
                         '<div id="content">\n',
                         '<script>\n')
    
    for(iData in 1:length(.RIGHT$searchArray))
      tempArray2 <- paste0(tempArray2, .RIGHT$searchArray[iData], "\n")
    
    tempArray2 <- paste0(tempArray2, '\n</script>\n',
                         '</div>\n</div>\n</div>\n')
    
    .RIGHT$searchArray <- tempArray2
  } # if
  
  if(length(.RIGHT$structArray) != 0) {
    tempArray <- c("<script>", .RIGHT$structArray, "</script>", .RIGHT$searchArray, tempArray)
  } # if
  
  return(c(tempArray, "</div>"))
  
} # function createDiv

# Create script block:
createScript <- function(scriptArray = NULL) {
  
  if (is.null(scriptArray)) {
    return(NULL)
  } # if 
  
  return(c("<script>",
           paste0("  ", scriptArray),
           "</script>"))
  
} # function createScript

# Create footer block for copyright statement:
createFooter <- function() {
  
  return(c('<div id="footer">',
           '<p id="copyright">&copy; 2015 - <a href="#">The RIGHT team</a></p>',
           '<p id="dont-delete-this">E-mail : <a href="mailto:right-user@googlegroups.com">right-user@googlegroups.com</a></p>',
           "</div>"))
  
} # function createFooter

# Assemble the body:
createBody <- function() {
  
  # Links and sourced scripts:
  divArray <- createDiv(.RIGHT$divArray, .RIGHT$flagServer)
  
  if (!is.null(divArray)) {
    divArray <- paste0("  ", divArray)
  } # if
  
  scriptArray <- createScript(.RIGHT$scriptArray)
  
  if (!is.null(scriptArray)) {
    scriptArray <- paste0("  ", scriptArray)
  } # if
  
  return(c("<body>", "",
           divArray, if (!is.null(divArray)) "" else NULL, 
           scriptArray, if (!is.null(scriptArray)) "" else NULL,
           .RIGHT$serverScript,
           paste0("  ", createFooter()), "",
           "</body>"))
  
} # function createBody
