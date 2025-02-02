## Manipulate variables --> Categorical variables

output$categorical.variables = renderUI({
  get.data.set()
  isolate({
    if(input$selector%in%"Categorical variables"){
      categorical.variables.panel(get.data.set())
    }
  })
})

output$categorical.main.panel = renderUI({
  input$categorical_variables_select1
  isolate({
    if(!is.null(input$categorical_variables_select1)&&
         input$categorical_variables_select1%in%"Reorder levels"){
      reorder.main.panel()
    }else if(!is.null(input$categorical_variables_select1)&&
               input$categorical_variables_select1%in%"Collapse levels"){
      collapse.main.panel()
    }else if(!is.null(input$categorical_variables_select1)&&
               input$categorical_variables_select1%in%"Rename levels"){
      rename.levels.main.panel()
    }else if(!is.null(input$categorical_variables_select1)&&
               input$categorical_variables_select1%in%"Combine categorical"){
      combine.main.panel()
    }
  })
})

output$categorical.side.panel = renderUI({
  input$categorical_variables_select1
  get.data.set()
  isolate({
    if(!is.null(input$categorical_variables_select1)&&
         input$categorical_variables_select1%in%"Reorder levels"){
      reorder.sidebar.panel(get.data.set())
    }else if(!is.null(input$categorical_variables_select1)&&
               input$categorical_variables_select1%in%"Collapse levels"){
      collapse.sidebar.panel(get.data.set())
    }else if(!is.null(input$categorical_variables_select1)&&
               input$categorical_variables_select1%in%"Rename levels"){
      rename.levels.sidebar.panel(get.data.set())
    }else if(!is.null(input$categorical_variables_select1)&&
               input$categorical_variables_select1%in%"Combine categorical"){
      combine.sidebar.panel(get.data.set())
    }
  })
})

## Manipulate variables --> Categorical variables --> Reorder levels


observe({
  input$select.reorder.column
  isolate({
    if(!is.null(input$select.reorder.column) && input$select.reorder.column %in% colnames(get.data.set())) {
      updateTextInput(session, "recorder_variable_newname", 
                      value = paste0(input$select.reorder.column, ".reord", sep = ""))
    }
  })
})




observe({
  input$reorder
  isolate({
    if(!is.null(input$select.reorder.column) && input$select.reorder.column %in% colnames(get.data.set())) {
      var = input$select.reorder.column
      if(!is.null(input$recorder_variable_newname) && !grepl("^\\s*$", input$recorder_variable_newname)) {
        name = input$recorder_variable_newname
        if(!is.null(input$recorder_sort_levels) && input$recorder_sort_levels == "manually") {
          if(!is.null(input$select.reorder.item) && length(input$select.reorder.item) == length(unique(get.data.set()[[input$select.reorder.column]]))) {
            levels = as.character(input$select.reorder.item)
            data = iNZightTools::reorderLevels(get.data.set(), var, levels, name = name)
            updatePanel$datachanged = updatePanel$datachanged+1
            values$data.set = data
          }
          
        }
        else {
          data = iNZightTools::reorderLevels(get.data.set(), var, freq = TRUE, name = name)
          updatePanel$datachanged = updatePanel$datachanged+1
          values$data.set = data
        } 
      }
    }
  })
})



output$text_reorder = renderPrint({
  if(!is.null(input$select.reorder.column)&&!""%in%input$select.reorder.column){
    print(table(get.data.set()[,input$select.reorder.column]))
  }else{
    cat("Select a column!")
  }
})

observe({
  if(!is.null(input$select.reorder.column)){
    choices=""
    if(!"" %in% input$select.reorder.column){
      if(is.factor(get.data.set()[,input$select.reorder.column])){
        choices = levels(get.data.set()[,input$select.reorder.column])
      }else{
        choices = levels(as.factor(get.data.set()[,input$select.reorder.column]))
      }
    }
    updateSelectInput(session=session,inputId="select.reorder.item",selected="",choices=choices)
  }
})

## Manipulate variables --> Categorical variables --> Collapse levels

observe({
  input$select.collapse.column
  isolate({
    if(!is.null(input$select.collapse.column) && input$select.collapse.column %in% colnames(get.data.set())) {
      updateTextInput(session, "collapse_variable_newname", 
                      value = paste0(input$select.collapse.column, ".coll", sep = ""))
    }
  })
})


observe({
  if(!is.null(input$select.collapse.column)){
    choices=""
    if(!"" %in% input$select.collapse.column){
      if(is.factor(get.data.set()[,input$select.collapse.column])){
        choices = levels(get.data.set()[,input$select.collapse.column])
      }else{
        choices = levels(as.factor(get.data.set()[,input$select.collapse.column]))
      }
    }
    updateSelectInput(session=session,inputId="select.collapse.item",selected="",choices=choices)
  }
})


observe({
  input$select.collapse.item
  isolate({
    if(!is.null(input$select.collapse.item) && length(input$select.collapse.item) > 0) {
      if(length(input$select.collapse.item) == 1) {
        updateTextInput(session, "collapse_level_newname", 
                        value = input$select.collapse.item)
      }
      else if(length(input$select.collapse.item) > 1) {
        updateTextInput(session, "collapse_level_newname", 
                        value = paste0(input$select.collapse.item, collapse = "_"))
      }
    }
  })
})


output$text_collapse_1st = renderPrint({
  input$collapse
  if(!is.null(input$select.collapse.column)&&!""%in%input$select.collapse.column){
    print(table(get.data.set()[,input$select.collapse.column]))
  }else{
    cat("Select a column!")
  }
})

output$text_collapse_2nd = renderPrint({
  input$collapse
  if(!is.null(input$select.collapse.column)&&!""%in%input$select.collapse.column&&
       !is.null(input$select.collapse.item)&&!""%in%input$select.collapse.item){
    print(table(get.collapsed.column(get.data.set()[,input$select.collapse.column],input$select.collapse.item)))
  }else{
    cat("")
  }
})



observe({
  input$collapse
  isolate({
    if(!is.null(input$select.collapse.column) && input$select.collapse.column %in% colnames(get.data.set())) {
      var = input$select.collapse.column 
      if(!is.null(input$select.collapse.item) && length(input$select.collapse.item) > 1) {
        lvls = input$select.collapse.item
        if(!is.null(input$collapse_variable_newname) && !grepl("^\\s*$", input$collapse_variable_newname)
           && !is.null(input$collapse_level_newname) && !grepl("^\\s*$", input$collapse_level_newname)) {
          name = input$collapse_variable_newname
          lvlname = input$collapse_level_newname
          data = iNZightTools::collapseLevels(get.data.set(), var, lvls, lvlname, name)
          updatePanel$datachanged = updatePanel$datachanged+1
          values$data.set = data
        }
      }
    }
  })
})






output$rename.factors.inputs = renderUI({
  input$select.rename.column
  get.data.set()
  isolate({
    if(!is.null(input$select.rename.column)&&!input$select.rename.column%in%""){
      rename.factors.textfields(levels(get.data.set()[,input$select.rename.column]))
    }
  })
})

output$text_rename = renderPrint({
  input$select.rename.column
  get.data.set()
  isolate({
    if(!is.null(input$select.rename.column)&&!input$select.rename.column%in%""){
      print(summary(get.data.set()[,input$select.rename.column]))
    }else{
      cat("")
    }
  })
})

observe({
  input$rename.levs
  isolate({
    if(!is.null(input$rename.levs)&&input$rename.levs>0){
      indexes1= grep("^factor[0-9]+$",names(input))
      new.levels = c()
      for(i in 1:length(indexes1)){
        new.levels[i] = input[[names(input)[indexes1[i]]]]
        if(is.null(new.levels[i])||new.levels[i]%in%""){
          new.levels[i] = levels(get.data.set()[,input$select.rename.column])[i]
        }
      }
      temp = rename.levels(get.data.set(),input$select.rename.column,new.levels)
      if(!is.null(temp)){
        updatePanel$datachanged = updatePanel$datachanged+1
        values$data.set = temp
        updateSelectInput(session,"select.rename.column",selected=0)
      }
    }
  })
})

## Manipulate variables --> Categorical variables --> Combine levels

output$text_combine = renderPrint({
  if(length(input$select.combine.columns)>0){
    temp = combine.levels(get.data.set(),input$select.combine.columns)
    print(table(temp[,ncol(temp)]))  
  }else{
    cat("Please select a set of columns")
  }
})

observe({
  input$combine
  isolate({
    if(!is.null(input$combine)&&input$combine>0){
      temp = combine.levels(get.data.set(),input$select.combine.columns)
      if(!is.null(temp)){
        updatePanel$datachanged = updatePanel$datachanged+1
        values$data.set = temp
      }
    }
  })
})
