
 <strong>Introduction and Scope </strong>
 
We have proposed a decentralized privacy-preserving contact tracing protocol with both active and passive participants.
Active participants broadcast BLE beacons with pseudo-random IDs, while passive participants model conservative users who do not broadcast BLE beacons but still listen to the broadcasted BLE beacons. We analyze the proposed protocol and discuss a set of interesting properties. The proposed protocol is evaluated using both a face-to-face individual interaction dataset and five real-world BLE datasets. Our simulation results demonstrate that the proposed DP-ACT protocol outperforms the state-of-the-art protocols in the presence of passive users.


 <strong>Datasets </strong>
 We have evaluated the proposed \PCT{} protocol using  a  face-to-face individual interaction dataset  and five real-world  BLE datasets.
 * <strong> Face-to-Face Datasets </strong>
We have considered [InVS15 dataset](https://epjdatascience.springeropen.com/articles/10.1140/epjds/s13688-018-0140-1). InVS15 contains the face-to-face interactions  of individuals measured during 12 days in an office building in France in 2015. We assume that all participants use COVID-19 contact-tracing mobile applications. 
 * <strong> Real-World  BLE Datasets </strong>
We consider  [real-world BLE datasets](https://github.com/DP-3T/bt-measurements/tree/ba9f73962b35260e12e2c0a8a37af5c6195d22a8)collected considering five different scenarios: dining together at the table, "scenario01-lunch"; riding a train together, "scenario02-train";  working together in an open-space setting, "scenario03-work";  waiting in line at the supermarket, "scenario04-queue", and mingling in a club/bar, "scenario05 -party". %and participate in a gym class, "scenario06-movement."  
 These datasets were collected in laboratory conditions, and 20 users participated in these data collections (the information regarding 2 participants is missed, and the datasets are collected by the other 18 users) with different smartphone models. The duration of the data collection for each of these datasets is 30 minutes.

  <strong> Assuptions and Measures</strong>
 In our simulations, we consider 1,000  runs with random COVID-19 infected users and random indexes for \silent{} users. The \emph{high-risk case  detection probability} is defined as the ratio of the detected high-risk cases to the total number of the high-risk cases, averaged over these  1,000  runs. A high-risk case is a person who has a high-risk contact with an infected person (the announced ones or the ones who are infected by announced ones and can transfer the virus to others after 4 days). The \emph{COVID-19 percentage} is also defined as the number of announced COVID-19 infected users to the total number of users. As discussed before, we assume that the \silent{} users do not install the application based on the DP-3T protocol. 

   <strong> Codes</strong>

   
 <strong>License and copyright </strong>
 
 Copyright of the experimental data and code belongs to Lund University and EPFL ?. For other uses of codes, please reach out via e-mail.
