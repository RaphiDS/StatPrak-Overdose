## Set-up
library(tidyverse)
## create new, cleaned dataset for 2019 for everyone to use
load("Daten bearbeitet/combi_redu_data.Rdata")
data2019 <- allfilterdata %>%
  filter (year == 2019)
#-------------------------------------------------------------------------------
## AGE grouped into allocated Categories of NSDUH
age.grouped <- data2019 %>%
  select(catage) %>%
  pivot_longer(cols = everything(), names_to = "variable", values_to = "Group") %>%
  group_by(Group) %>%
  summarize(count =n()/56136)

ggplot(age.grouped, aes(x= factor(Group),y = count, fill = factor(Group, labels = c("12-17", "18-25", "26-34", "35+")))) +
  geom_col() +
  labs(title = "Age in allocated Groups", y = "Percentage", fill = "Age groups", x = "Group") +
  theme_light() +
  theme(
    axis.title = element_text(size = 20),  # Achsentitel
    axis.text  = element_text(size = 20),  # Achsbeschriftungen
    legend.position = "none"  # Legendentext
  ) +
  scale_x_discrete(labels = c("12-17", "18-25", "26-34", "35+"))

#-------------------------------------------------------------------------------
## Distribution Race
Race.Destr <- data2019 %>%
  select(NEWRACE2) %>%
  pivot_longer(cols = everything(), names_to = "Var", values_to = "Answer") %>%
  group_by(Answer) %>%
  summarize(count = n()) %>%
  mutate(count = count/56136)

ggplot(Race.Destr, aes(x = factor(Answer), y = count, fill = factor(Answer)))+
  geom_col()+
  scale_x_discrete(labels = c("1" = "White", "2" = "Afr.Am", "3" = "Am/AK Native", "4" ="Other Pac Isl", "5" = " Asian", "6" = "more than one Race", "7" = "Hispamic"),
                   guide = guide_axis(angle = 45)) +
  labs(y = "Anteil", x = "Herkunft") +
  theme_light() +
  theme(
    axis.title = element_text(size = 20),  # Achsentitel
    axis.text  = element_text(size = 20),  # Achsbeschriftungen
    legend.position = "none"  # Legendentext
  )

#-------------------------------------------------------------------------------
## Nicotine Dependency Gender
Nic.Dependency.Gender <- data2019 %>%
  select(ndssdnsp,irsex) %>%
  filter(ndssdnsp == 1) %>%
  group_by(irsex) %>%
  summarise(count = n()) %>%
  mutate (count = count/56136)
 
ggplot(Nic.Dependency.Gender, aes(x = factor(irsex), y = count))+
  geom_col()+
  scale_x_discrete(labels = c("1" = "Männer", "2" = "Frauen"))+
  labs(x = "Geschlecht", y = "Anteil")+
  theme_light() +
  theme(
    axis.title = element_text(size = 20),  # Achsentitel
    axis.text  = element_text(size = 20),  # Achsbeschriftungen
    legend.position = "none"  # Legendentext
  )
#-------------------------------------------------------------------------------
## Nicotine Dependency Age
Nic.Dependency.Age <- data2019 %>%
  select(catage, ndssdnsp) %>%
  filter(ndssdnsp == 1) %>%
  group_by(catage) %>%
  summarise(count = n()) %>%
  mutate(count = count/56136)

ggplot(Nic.Dependency.Age, aes(x = factor(catage), y = count))+
  geom_col()+
  scale_x_discrete(name = "Gruppierung",labels = c("12-17", "18-25", "26-34", "35+"))+
  labs( x = " ", y = "Anteil")+
  theme_light() +
  theme(
    axis.title = element_text(size = 20),  # Achsentitel
    axis.text  = element_text(size = 20),  # Achsbeschriftungen
    legend.position = "none"  # Legendentext
  )
#-------------------------------------------------------------------------------
## Nikotin Dependency (last month) and Race
Nikotin.Dependence.Race <- data2019 %>%
  select(NEWRACE2, ndssdnsp) %>%
  filter (ndssdnsp == 1)%>%
  group_by(NEWRACE2) %>%
  summarise(count = n()) %>%
  mutate(count = count /56136)

ggplot(Nikotin.Dependence.Race, aes(x = factor(NEWRACE2), y = count))+
  geom_col()+
  scale_x_discrete(labels = c("1" = "Weisse",
                              "2" = "Afro- \nAmerikaner",
                              "3" = "Am/Ak \nIndigene",
                              "4" = "Indigene \nHawaii \n/Paz. Inseln",
                              "5" = "Asiaten",
                              "6" = "Gemischt",
                              "7" = "Hispanisch"))+
  labs(x = "Ethnie", y = "Anteil")+
  theme_light() +
  theme(
    axis.title = element_text(size = 15),  # Achsentitel
    axis.text  = element_text(size = 15),  # Achsbeschriftungen
    legend.position = "none"  # Legendentext
  )



#-------------------------------------------------------------------------------
##Generell Drug Dependency / Abuse
Drug.Dependency.Abuse <- data2019 %>%
  select(alcyr, cocyr, heryr, depndalc, depndcoc, depndher, abusealc, abusecoc,abuseher) %>%
  mutate(ID = row_number()) %>%  # Add an ID column for pivoting
  pivot_longer(cols = -ID, names_to = "Variable", values_to = "Value") %>%
  mutate(
    Substance = case_when(
      str_detect(Variable, "alc") ~ "Alkohol",
      str_detect(Variable, "coc") ~ "Cokain",
      str_detect(Variable, "her") ~ "Heroin"
    ),
    Condition = case_when(
      str_detect(Variable, "depnd") ~ "Dependent",
      str_detect(Variable, "abuse") ~ "Abuse",
      str_detect(Variable, "yr") ~ "Use"
    )
  ) %>%
  filter(Value == 1)  # Keep only cases where the flag is 1 (indicating presence)

# Create stacked bar plot
ggplot(Drug.Dependency.Abuse, aes(x = Substance, fill = Condition)) +
  geom_bar(position = "fill") +
  labs(title = "Substanzkonsum, Abhängigkeit und Missbrauch im letzten Jahr",
       x = "Substanz")+
  theme_light() +
  theme(
    axis.title = element_text(size = 20),  # Achsentitel
    axis.text  = element_text(size = 15),  # Achsbeschriftungen
    legend.position = "none"  # Legendentext
  )

## Drug Dependency based on gender
Drug.Dependency.Gender <-data2019 %>%
  select(irsex, depndcoc, depndalc, depndher) %>%
  pivot_longer(cols = c(depndcoc,depndher, depndalc), names_to = "Drug", values_to = "Usage") %>%
  filter(Usage == 1)

ggplot(Drug.Dependency.Gender, aes(x = factor(Drug), fill = factor(irsex)))+
  geom_bar(position = "fill")+
  #geom_line(y = 0.5)+
  labs(title = "Drug Dependency by Gender")+
  scale_x_discrete(labels = c("depndalc" = "Alkohol", "depndcoc" = "Cokain", "depndher" = "Heroin"))+
  scale_fill_manual(labels = c("1" = "Männer", "2" = "Frauen"), values =c("1" = "darkblue", "2" = "maroon"))+
  labs(title = "Abhängigkeit von Männern und Frauen", x = "Substanz")+
  theme_light() +
  theme(
    axis.title = element_text(size = 15),  # Achsentitel
    axis.text  = element_text(size = 15),  # Achsbeschriftungen
  )

#-------------------------------------------------------------------------------
## Drug Dependency by age group
Drug.Dependency.Age <- data2019 %>%
  select(catage,depndcoc,depndher, depndalc) %>%
  pivot_longer(cols = c(depndcoc, depndher, depndalc), names_to = "Drug", values_to = "Usage") %>%
  filter (Usage == 1)

ggplot(Drug.Dependency.Age, aes(x = factor(catage), fill = factor(Drug)))+
  geom_bar(position = "fill")+
  scale_fill_discrete(name = "Drogen",labels = c("depndalc" = "Alkhol","depndcoc" = "Cokain", "depndher" = "Heroin"))+
  scale_x_discrete(labels = c("1" = "12-17", "2" = "18-25", "3" = "26-34", "4" = "35+"))+
  labs(title = "Abhängigkeit der Altersgruppen", x = "Gruppierung")+
  theme_light() +
  theme(
    axis.title = element_text(size = 20),  # Achsentitel
    axis.text  = element_text(size = 15),  # Achsbeschriftungen
    legend.position = "bottom"  # Legendentext
  )
#------------------------------------------------------------------------------
## Drug Dependency and Race
Dependent.Users.Race <- data2019 %>%
  select(NEWRACE2, depndcoc, depndalc, depndher) %>%
  pivot_longer(cols = c(depndcoc,depndher, depndalc), names_to = "Drug", values_to = "Usage") %>%
  filter(Usage == 1)

ggplot(Dependent.Users.Race , aes(x = factor(NEWRACE2), fill = factor(Drug)))+
  geom_bar(position = "fill")+
  scale_x_discrete(labels = c("1" = "Weisse",
                              "2" = "Afro \nAmerikaner",
                              "3" = "Am/Ak \nIndigene",
                              "4" = "Indigene Hawaii \n/Paz. Inseln",
                              "5" = "Asiaten",
                              "6" = "Gemischt",
                              "7" = "Hispanisch")) +
  scale_fill_discrete(name = "Drogen",labels = c("depndalc" = "Alkhol","depndcoc" = "Cokain", "depndher" = "Heroin"))+
  labs(title = "Abhängigkeit der Ethnien", x = "Gruppen")+
  theme_light() +
  theme(
    axis.title = element_text(size = 15),  # Achsentitel
    axis.text  = element_text(size = 15),  # Achsbeschriftungen
    legend.position = "bottom"  # Legendentext
  )

## Drogen und Einkommen
Drogen.Einkommen <- data2019 %>%
  select(depndalc, depndcoc,depndher, income) %>%
  mutate(Dependency = case_when(
    depndalc == 1 & depndcoc == 0 & depndher == 0 ~ "Alkohol",
    depndcoc == 1 & depndalc == 0 & depndher == 0 ~ "Kokain",
    depndher == 1 & depndalc == 0 & depndcoc == 0 ~ "Heroin",
    depndalc == 1 & depndcoc == 1 | depndalc == 1 & depndher == 1 | depndcoc == 1 & depndher == 1 ~ "Mehrfachabhängigkeit"
  )) %>%
  filter(!is.na(Dependency)) %>%
  mutate(Dependency = factor(Dependency, levels = c("Alkohol", "Kokain", "Heroin", "Mehrfachabhängigkeit"))) %>%
  group_by(income, Dependency) %>%
  ggplot(aes(x = factor(income), fill = Dependency))+
  geom_bar(position = "fill")+
  geom_vline(xintercept = 3, linetype = "dotted", color = "black", size = 1 )+
  scale_fill_manual(name = "Drogen",
                    values = c("Alkohol" = "#0072B2",  # Blau
                               "Kokain" = "#E69F00",  # Gelb
                               "Heroin" = "#CC79A7",  # Rosa
                               "Mehrfachabhängigkeit" = "grey30")) +  # Grau
  scale_x_discrete(labels = c("1" = "Weniger als 20.000", "2" = "20.000 - 49.999", "3" = "50.000 - 74.999", "4" = "75.000+"))+
  labs(x = "Familieneinkommen in $", y = "Anteil")+
  theme_light() +
  theme(
    axis.title = element_text(size = 20),  # Achsentitel
    axis.text  = element_text(size = 20),  # Achsbeschriftungen
    legend.title = element_text(size = 17,5),
    legend.text = element_text(size = 17,5),
    legend.position = "bottom",
  )
Drogen.Einkommen
## Drogen und Armut
Drogen.Armut <- data2019 %>%
  select(POVERTY3, depndalc, depndcoc, depndher) %>%
  pivot_longer(cols = c(depndcoc,depndher, depndalc), names_to = "Drug", values_to = "Usage")%>%
  filter(Usage == 1, POVERTY3 > 0) %>%
  ggplot (aes(x = factor(POVERTY3), fill = factor(Drug)))+
  geom_bar(position = "fill")+
  scale_fill_manual(name = "Drogen",
                    labels = c("depndalc" = "Alkohol","depndcoc" = "Kokain", "depndher" = "Heroin"),
                    values = c("#0072B2","#E69F00", "#CC79A7"))+
  scale_x_discrete(labels = c("1" = "Armutsbedroht", "2" = "Gehalt 2x Armutsquote", "3" = "Gehalt mehr als 2x"))+
  labs(x = "Familieneinkommen in $", y = "Anteil")+
  theme_light() +
  theme(
    axis.title = element_text(size = 25),  # Achsentitel
    axis.text  = element_text(size = 15),  # Achsbeschriftungen
    legend.title = element_text(size = 17,5),
    legend.text = element_text(size = 10)
  )

Drogen.Armut
## Bildungsgrad Drogen
Substanz.Bildung <- data2019 %>%
  select(eduhighcat, depndalc, depndcoc,depndher) %>%
  pivot_longer(cols = c(depndcoc,depndher, depndalc), names_to = "Drug", values_to = "Usage")%>%
  filter(Usage == 1, eduhighcat < 5) %>%
  ggplot(aes(x = factor(eduhighcat), fill = factor(Drug)))+
  geom_bar(position = "fill")+
  scale_fill_manual(name = "Drogen",
                    labels = c("depndalc" = "Alkohol","depndcoc" = "Kokain", "depndher" = "Heroin"),
                    values = c("#0072B2","#E69F00", "#CC79A7"))+
  scale_x_discrete(labels = c("1" = "Mittlere reife", "2" = "High School", "3" = "Uni Credits" ,"4" = "Bachelor"))+
  labs(x = "Höchster Abschluss", y = "Anteil")+
  theme_light() +
  theme(
    axis.title = element_text(size = 15),  # Achsentitel
    axis.text  = element_text(size = 15),  # Achsbeschriftungen
    legend.title = element_text(size = 17,5),
    legend.text = element_text(size = 10)
  )
Substanz.Bildung

##### ODDS
Drogen.Gehalt.Kreuztab <- data2019%>%
  select(depndalc, depndcoc, depndher,income) %>%
  mutate(
    Dependency = case_when(
      depndalc == 0 & depndcoc == 0 & depndher == 0 ~ "Keine Abhängigkeit",
      depndalc == 1 & depndcoc == 0 & depndher == 0 ~ "Alkohol",
      depndalc == 0 & depndcoc == 1 & depndher == 0 ~ "Kokain",
      depndalc == 0 & depndcoc == 0 & depndher == 1 ~ "Heroin",
      TRUE ~ "Mehrfache Abhängigkeit"
    )
  ) %>%

#------------------------------------------------------------------------------
##############
#MENTAL HEALTH
#############

## MDE : Mayor Depressive Episode
MDE.Age <- data2019%>%
  select(amdeyr,ymdeyr, CATAG2) %>%
  pivot_longer(cols =c(amdeyr,ymdeyr), names_to = "MDE", values_to = "Answer") %>%
  filter(Answer > 0)%>%
  mutate (total = n())%>% 
  group_by(CATAG2, Answer) %>%
  summarise(count = n(), total = first(total)) %>%
  mutate(count = count/total)

ggplot(MDE.Age, aes(x = factor (CATAG2), y = count, fill = factor(Answer)))+
  geom_col(position = "dodge")+
  scale_x_discrete(labels = c("1"= "12-17", "2" = "18-25", "3" = "26+"))+
  labs( title = "MDE und Altersgruppen", x = "Altersgruppen", y = "Anteil")+
  theme_light() +
  theme(
    axis.title = element_text(size = 15),  # Achsentitel
    axis.text  = element_text(size = 15),  # Achsbeschriftungen
    legend.position = "bottom"  # Legendentext
  )

#-------------------------------------------------------------------------------
## Drug Dependency and 'Degree' of Mental illness
Drug.Dependency.MI <- data2019 %>%
  select(depndalc,depndcoc,depndher,MI_CAT_U) %>%
  filter (MI_CAT_U >= 0) %>%
  pivot_longer(cols = c(depndalc, depndcoc,depndher), names_to = "Drug", values_to = "Response") %>%
  filter( Response == 1) 

ggplot(Drug.Dependency.MI, aes( x = factor(MI_CAT_U), fill = factor(Drug)))+
  geom_bar(position = "fill")+
  scale_x_discrete(labels = c("0" = "Keine Mentalen \nGesundheitsprobleme" , "1" = "'Milde' Mentale \nErkrankung", "2" = " 'Moderate' Mentale \nErkrankung", "3" = "Ernste Mentale \nErkrankungen"),
                   guide = guide_axis(angle = 45))+
  labs(x = "Art der Erkrankung", y = "Anteil")

##GLeicher Plot, nur achsen vertauscht
ggplot(Drug.Dependency.MI, aes(x = factor(Drug), fill = factor(MI_CAT_U)))+
  geom_bar(position = "fill")+
  scale_x_discrete(labels = c("depndalc" = "Alkohol", "depndcoc" = "Cokain","depndher" = "Heroin"))+
  labs(title = "Substanzabhängigkeit und Mentale Gesundheit", x = " Substanz")+
  scale_fill_discrete(name = "",labels = c("0" = "Keine Mentalen Gesundheitsprobleme" , "1" = "'Milde' Mentale Erkrankung", "2" = " 'Moderate' Mentale Erkrankung", "3" = "Ernste Mentale Erkrankungen"))+
  theme_light() +
  theme(
    axis.title = element_text(size = 15),  # Achsentitel
    axis.text  = element_text(size = 20),  # Achsbeschriftungen
    legend.position = "bottom"  # Legendentext
  )

#-------------------------------------------------------------------------------
## Adult Mental Heath / Substance Treatment
## Variable zur Rekodierung: leute die Mh Treatment bekommen haben, Treatment for Drug Use
Adult.Treatment <- data2019 %>%
  select(depndalc, depndcoc, depndher,rcvmhnsptx, rcvsptxnmh, rcvmhasptx) %>%
  pivot_longer(cols = c(depndalc, depndcoc, depndher), names_to = "Drug", values_to = "Answer") %>%
    pivot_longer(cols = c(rcvmhnsptx, rcvsptxnmh, rcvmhasptx), names_to = "Treatment", values_to = "Response") %>%
  filter(Answer == 1, Response == 1)

ggplot(Adult.Treatment, aes(x = factor(Drug), fill = factor(Treatment)))+
  geom_bar(position = "fill") +
  scale_x_discrete(labels = c("depndalc" = "Alkhol","depndcoc" = "Cokain", "depndher" = "Heroin"))+
  scale_fill_discrete(name = "", labels = c("rcvmhnsptx" = "Behandlung für MI", "rcvsptxnmh" = "Behandlung für Substanzkonsum", "rcvmhasptx" = "Behandlung beides"))+
  labs(title = "Substanzkonsum und Art der Behandlung", x = "SUbstanz")+
  theme_light() +
  theme(
    axis.title = element_text(size = 15),  # Achsentitel
    axis.text  = element_text(size = 20),  # Achsbeschriftungen
    legend.position = "bottom"  # Legendentext
  )


#######
#YOUTH
######
#Overall Substance and Mental Health


#-------------------------------------------------------------------------------
## Mental Health Treatment and Substance Abuse Treatment
Youth.Treatment <-data2019 %>%
  select(ymhnsptx, ysptxnmh, ymhasptx, depndalc, depndcoc, depndher) %>%
  pivot_longer(cols = c(depndalc, depndcoc, depndher), names_to = "Drug", values_to = "Answer") %>%
  pivot_longer(cols = c(ymhnsptx, ysptxnmh, ymhasptx), names_to = "Treatment", values_to = "Response") %>%
  filter(Answer == 1, Response == 1)

ggplot(Youth.Treatment, aes(x = factor(Drug), fill = factor(Treatment)))+
  geom_bar(position = "fill")+
  scale_x_discrete(labels = c("depndalc" = "Alkhol","depndcoc" = "Cokain", "depndher" = "Heroin"))+
  scale_fill_discrete(labels = c("ymhnsptx" = "Behandlung für MI", "ysptxnmh" = "Behandlung für Substanzkonsum", "ymhasptx" = "Behandlung für beides"))+
  labs(title = "SUbstanzkonsum und Art der Behandlung YOUTH", x = "SUbstanz")+
    theme_light() +
    theme(
      axis.title = element_text(size = 15),  # Achsentitel
      axis.text  = element_text(size = 20),  # Achsbeschriftungen
      legend.position = "bottom"  # Legendentext
    )
  
  
##-----------------------------------------------------------------------------
## MDE and Drugs Youth
Youth.MDE.Drugs <- data2019 %>%
    select(ymdeyr, depndalc,depndcoc,depndher)%>%
    pivot_longer(cols =c(depndalc, depndcoc, depndher), names_to = "Drug", values_to = "Response") %>%
    group_by(Drug) %>%
    mutate (total = n()) %>% 
    filter(Response == 1, ymdeyr == 1) %>%
    summarise(count = n(), total = first(total)) %>%
    mutate(count = count/total)

  ggplot(Youth.MDE.Drugs, aes(x = factor(Drug), y = count))+
    geom_col()+
    scale_x_discrete(labels = c("depndalc" = "Alkhol","depndcoc" = "Cokain", "depndher" = "Heroin"))+
    labs(title = "MDE und Substanzkonsum", x = "Substanz")

 
  
  #-------------------------------------------------------------------------
 
  ### Mental health gender
  Drug.Dependency.Gender <- data2019 %>%
    select(depndalc, depndcoc, depndher, MI_CAT_U, irsex) %>%
    mutate(
      Dependency = case_when(
        depndalc == 1 & depndcoc == 0 & depndher == 0 ~ "Alkohol",
        depndcoc == 1 & depndalc == 0 & depndher == 0 ~ "Kokain",
        depndher == 1 & depndalc == 0 & depndcoc == 0 ~ "Heroin",
        depndalc == 1 & depndcoc == 1 | depndalc == 1 & depndher == 1 | depndcoc == 1 & depndher == 1 ~ "Mehrfachabhängigkeit",
        TRUE ~ "Keine Abhängigkeit"
      )
    ) %>%
    filter(MI_CAT_U >= 0) %>%  # Mehrfachabhängigkeit wird jetzt nicht mehr ausgeschlossen
    group_by(Dependency, MI_CAT_U, irsex) %>%
    summarise(count = n(), .groups = "drop") 
  
  ggplot(Drug.Dependency.Gender, aes( x = Dependency))+
    geom_col
  
  #########
  #Appendix
  #########

  

  

  
  
  