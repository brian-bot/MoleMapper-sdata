###########################################
##  MoleMapper access restrictions
###########################################
require(synapseClient)
synapseLogin()


#######################################################################
## Set up the controlled access - tier 3 - all MoleMapper datasets except images
#######################################################################
entityIds3 <- list("syn6829807", "syn6829808", "syn6829809", "syn6829810")
subjectIds3 <- lapply(entityIds3, function(x){list(id=x,type="ENTITY")})
openJiraIssue3 <- FALSE # set to true or false to control whether the web portal allows to open a Jira issue
actText3 <- c('<div style="font-size:14px" class="markdown margin-left-10 margin-right-15"> 
<h4>To qualify for access to MoleMapper data, you must:</h4>
<ul>
  <li> Become a <a href="http://docs.synapse.org/articles/accounts_certified_users_and_profile_validation.html" target="_blank">Synapse Certified User</a> with an enhanced and validated user profile
  <li> Submit your Intended Data Use statement to <b>act@synapse.org</b> from the email address associated with your validated Synapse profile. <b><i>Note that your Intended Data Use statement will be posted publically on Synapse</i></b>
  <li> Agree to comply with the data-specific Conditions for Use when prompted
  <li> Researchers wishing to access the mole images must also submit proof that their research plan was approved by an accredited ethics board/IRB
</ul>
<br>
<p>See the full instructions for requesting data access on the <a href="https://www.synapse.org/#!Synapse:syn5576734/wiki/391119">How to access the MoleMapper data</a> page</p>')
ar3 <- list(concreteType="org.sagebionetworks.repo.model.ACTAccessRequirement", 
            subjectIds=subjectIds3, 
            accessType="DOWNLOAD", 
            actContactInfo=actText3, 
            openJiraIssue=openJiraIssue3)
ar3 <- synRestPOST("/accessRequirement", ar3)

#######################################################################
## Set up the controlled access - tier 3 - images only
#######################################################################
entityIds3images <- list("syn6829811")
subjectIds3images <- lapply(entityIds3images, function(x){list(id=x,type="ENTITY")})
openJiraIssue3 <- FALSE # set to true or false to control whether the web portal allows to open a Jira issue
actText3images <- c('<div style="font-size:14px" class="markdown margin-left-10 margin-right-15"> 
<h4>To qualify for access to MoleMapper data, you must:</h4>
<ul>
  <li> Become a <a href="http://docs.synapse.org/articles/accounts_certified_users_and_profile_validation.html" target="_blank">Synapse Certified User</a> with an enhanced and validated user profile
  <li> Submit your Intended Data Use statement to <b>act@synapse.org</b> from the email address associated with your validated Synapse profile. <b><i>Note that your Intended Data Use statement will be posted publically on Synapse</i></b>
  <li> Agree to comply with the data-specific Conditions for Use when prompted
  <li> Researchers wishing to access the mole images must also submit proof that their research plan was approved by an accredited ethics board/IRB
</ul>
<br>
<p>See the full instructions for requesting data access on the <a href="https://www.synapse.org/#!Synapse:syn5576734/wiki/391119">How to access the MoleMapper data</a> page</p>')
ar3images <- list(concreteType="org.sagebionetworks.repo.model.ACTAccessRequirement", 
                  subjectIds=subjectIds3images, 
                  accessType="DOWNLOAD", 
                  actContactInfo=actText3images, 
                  openJiraIssue=openJiraIssue3)
ar3images <- synRestPOST("/accessRequirement", ar3images)

#######################################################################
## Add Restricted (Tier 2) Access Control to all MoleMapper data tables
#######################################################################
entityIds2 <- list("syn6829807", "syn6829808", "syn6829809", "syn6829810", "syn6829811")
subjectIds2 <- lapply(entityIds2, function(x){list(id=x,type="ENTITY")})
actText2 <- c('<div style="font-size:14px" class="markdown margin-left-10 margin-right-15">
<h4>Access to the data requires that you electronically agree to the following Conditions for Use when prompted:</h4>
<ul>
  <li> You confirm that you will not attempt to re-identify research participants for any reason, including for re-identification theory research
  <li> You reaffirm your commitment to the Synapse Awareness and Ethics Pledge
  <li> You agree to abide by the guiding principles for responsible research use and data handling as described in the <a href="http://docs.synapse.org/articles/governance.html" target="_blank">Synapse Governance documents</a>
  <li> You commit to keeping these data confidential and secure
  <li> You agree to use these data exclusively as described in your submitted Intended Data Use statement
  <li> You understand that these data may not be used for commercial advertisement or to re-contact research participants
  <li> You agree to report any misuse or data release, intentional or inadvertent to the ACT within 5 business days by emailing <b>act@sagebase.org</b>
  <li> You agree to publish findings in open access publications
  <li> You promise to acknowledge the research participants as data contributors and study investigators on all publication or presentation resulting from using these data as follows: 
  <i><b>"These data were contributed by users of the MoleMapper mobile application as part of the MoleMapper study developed by Sage Bionetworks and OHSU, and described in Synapse [doi:10.7303/syn5576734]."</b></i>
</ul>
<br>
<p>See the full instructions for requesting data access on the <a href="https://www.synapse.org/#!Synapse:syn5576734/wiki/391119">How to access the MoleMapper data</a> page</p>')
ar2 <- list(entityType="org.sagebionetworks.repo.model.TermsOfUseAccessRequirement", concreteType="org.sagebionetworks.repo.model.TermsOfUseAccessRequirement",
            subjectIds=subjectIds2, accessType="DOWNLOAD",
            termsOfUse=actText2)
ar2 <- synRestPOST("/accessRequirement", ar2)
