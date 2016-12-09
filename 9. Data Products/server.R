defaults = list("tail" = "lower","lower_bound" = "open","upper_bound" = "open")

shinyServer(function(input, output){ 
  output$tail = renderUI({
    selectInput(inputId = "tail",label = "Find Area:",
                  choices = c("Lower Tail"="lower","Upper Tail"="upper","Both Tails"="both","Middle"="middle"),
                  selected = "lower")
  })

  get_model_text = reactive({
    if (is.null(input$tail)){shiny:::flushReact(); return()}
    text = ""
    if (length(input$tail) != 0){
      if (input$tail == "lower") text = paste0("P(X ", "<", " a)")
      else if (input$tail == "upper") text = paste0("P(X ", ">", " a)")
      else if (input$tail == "middle") text = paste0("P(a ", "<", " X ", "<", " b)")
      else if (input$tail == "both") text = paste0("P(X ", "<", " a or X ", ">", " b)")
    }
    return(text)
  })
  output$model = renderText({
    get_model_text()
    })
  output$mean = renderUI({
    sliderInput("mu","Mean",value = 0,min = -50,max = 50)
  })
  output$sd = renderUI({
    sliderInput("sd","Standard deviation",value = 1,min = 0.1,max = 30,step=0.1)
  })
  output$num = renderUI({
      sliderInput("num","Number of observations",value = 50,min = 30,max = 1000,step=10)
  })
  output$a = renderUI({
    mu = input$mu; sd = input$sd
    if (is.null(mu)) mu = 0; if (is.null(sd)) sd = 1
    value = mu-1.96*sd; min = mu-4*sd; max = mu+4*sd; step = .01
    sliderInput("a", "a",value = value,min = min,max = max,step = step)
  })
  output$b = renderUI({
    if (is.null(input$tail)){shiny:::flushReact(); return()}
    if (input$tail %in% c("middle","both")){
      mu = input$mu; sd = input$sd
      if (is.null(mu)) mu = 0; if (is.null(sd)) sd = 1
      value = mu+1.96*sd; min = mu-4*sd; max = mu+4*sd; step = .01
      sliderInput("b", "b",value = value,min = min,max = max,step = step)
    }
  })
  
  output$plot = renderPlot({
    if (is.null(input$tail) | is.null(input$a)){shiny:::flushReact(); return()}
    L = NULL; U = NULL; error = FALSE
    if (input$tail == "lower" | input$tail == "equal") L = input$a
    else if (input$tail == "upper") U = input$a
    else if (input$tail %in% c("both","middle")){
      if (is.null(input$b)){shiny:::flushReact(); return()}
      L = input$a; U = input$b
      if (L > U) error = TRUE
    }

    if (error){
      plot(0,0,type='n',axes=FALSE,xlab="",ylab="",mar=c(1,1,1,1))
      text(0,0,"Error: Lower bound greater than upper bound.",col="red",cex=2)
    }
    
    else{
        M = NULL
        if (input$tail == "middle"){
          M = c(L,U); L = NULL; U = NULL
        }
       
        normTail <- function(m=0, s=1, n=NULL, L=NULL, U=NULL, M=NULL, xlim=NULL, ylim=NULL){
                if(is.null(xlim)[1]) xlim <- m + c(-1,1)*3.5*s
                temp <- diff(range(xlim))
                x <- seq(xlim[1] - temp/4, xlim[2] + temp/4, length.out=n)
                y <- dnorm(x, mean=m, sd=s)
                if(is.null(ylim)[1]) ylim <- range(c(0,y))
                
                plot(x, y, type='h', xlim=xlim, ylim=ylim, xlab='', ylab='', col=1)
                
                if(!is.null(L[1])){
                    region <- (x <= L)
                    X <- c(x[region][1], x[region], rev(x[region])[1])
                    Y <- c(0, y[region], 0)
                    polygon(X, Y, border=1, col="#1E90FF")
                }
                if(!is.null(U[1])){
                    region <- (x >= U)
                    X <- c(x[region][1], x[region], rev(x[region])[1])
                    Y <- c(0, y[region], 0)
                    polygon(X, Y, border=1, col="#1E90FF")
                }
                if(all(!is.null(M[1:2]))){
                    region <- (x >= M[1] & x <= M[2])
                    X <- c(x[region][1], x[region], rev(x[region])[1])
                    Y <- c(0, y[region], 0)
                    polygon(X, Y, border=1, col="#1E90FF")
                }
        }
        normTail(m=input$mu, s=input$sd, n=input$num, L=L, U=U, M=M)
    }
  })

  output$area = renderText({
    if (is.null(input$tail) | is.null(input$a)){shiny:::flushReact(); return()}
    L = input$a; U = NULL
    
    if (input$tail %in% c("both","middle")){
      if (is.null(input$b)){shiny:::flushReact(); return()}
        U = input$b
      error = FALSE
      if (L>U) error = TRUE
      if (error) return()
    }
    
    f = function(x) pnorm(x,input$mu,input$sd)
    val = NA
    if (input$tail == "lower") val = f(L)
    else if (input$tail == "upper") val = 1-f(L)
    else if (input$tail == "equal") val = f(L)
    else if (input$tail == "both") val = f(L) + (1-f(U))
    else if (input$tail == "middle") val = f(U) - f(L)
    
    text = paste(get_model_text(),"=",signif(val,3))
    text = sub("a",input$a,text)
    if (input$tail %in% c("both","middle")) 
      text = sub("b",input$b,text)
    text
  })
  
  output$about <- renderUI({
      HTML(paste("<b>The App:</b><br>
                This is a simple app to demonstrate the properties of a normal distribution and p-values through an intuitive, simple and comprehensive visualization.
                 By default the application loads the standard normal distribution.
                 The application allows the user to:<br>
                 <ul>
                 <li>Generate a normal disbution based on a mean and standard distribution
                 <li>Calculate the probabilty of the tail region - left, right, both tails or in between both tails.
                 </ul>
                <b>Properties:</b><br>
                <ul>
                    <li>It is symmetric around the point x = &mu;, which is the mean and also the median and mode of the distribution.
                    <li>The area under the curve and over the x-axis is unity.
                    <li>The simplest case of a normal distribution is known as the standard normal distribution. This is a special case when  &mu;=0 and  &sigma;=1.                    
                    <li>3-sigma rule or 68-95-99.7 (empirical) rule:
                    <ul>
                        <li>About 68% of values lie within 1 &sigma; away from the mean.
                        <li>About 95% of the values lie within 2 &sigma;.
                        <li>About 99.7% are within 3 &sigma;.
                    </ul>
                </ul><br>
                <b>Author:</b> Karthik Arumugham.<br>
                Built using Shiny by Rstudio and R, the Statistical Programming Language.<br>
                May 30, 2016<br>"))
  })
})