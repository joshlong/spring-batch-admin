<#import "/spring.ftl" as spring />
<div id="job">
	
	<#if launchable>
		<#assign launch_url><@spring.url relativeUrl="${servletPath}/jobs/${job.name}"/></#assign>
		<form id="launchForm" action="${launch_url}" method="POST">
	
			<#if launchRequest??>
				<@spring.bind path="launchRequest" />
				<@spring.showErrors separator="<br/>" classOrStyle="error" /><br/>
			</#if>
	
			<label for="launch">Job name=${job.name}</label><input id="launch" type="submit" value="Launch" name="launch" />
			<script type="text/javascript">
				Spring.addDecoration(new Spring.AjaxEventDecoration({
					elementId : "launch",
					event : "onclick",
					formId: "launchForm",
					params : {
						fragments: "body"
					}
				}));
			</script>
			<ol>
				<li><label for="jobParameters">Job Parameters (key=value
				pairs)</label><textarea id="jobParameters" name="jobParameters">${jobParameters}</textarea> 
				(<#if job.incrementable!false>Not incrementable<#else>Incrementable</#if>)</li>
			</ol>
	
			<br/><#if job.incrementable!false>
			<p>If the parameters are marked as "Incrementable" then the launch button launches the <em>next</em> 
			instance of the job in the sequence defined by the incrementer.  The old parameters are shown above,
			and they will passed into the configured incrementer. You can always add new parameters if you want to.</p>
			<#else>
			<p>If the parameters are marked as "Not incrementable" then the launch button launches an 
			instance of the job with the parameters shown.  You can always add new parameters if you want to.</p>
			</#if>

			<input type="hidden" name="origin" value="job"/>
		</form>
		<script type="text/javascript">
		    Spring.addDecoration(new Spring.ElementDecoration({
			elementId : "jobParameters",
			widgetType : "dijit.form.ValidationTextBox",
			widgetAttrs : { 
				invalidMessage : "Invalid job parameters (use name=value with comma or new line separators)!", 
				regExp : "([\\w\\.-_\\)\\(]+=.*[,\\n])*([\\w\\.-_\\)\\(]+=.*)",  
				required : true
			}
		    }));
		</script>
	</#if>
	
	<#if job?? && jobInstances?? && jobInstances?size!=0>
		
			<br/>
			<h2>Job Instances for Job (${job.name})</h2>
			
			<table title="Jobs Instances" class="bordered-table">
				<thead>
					<tr>
						<th>ID</th>
						<th>&nbsp;</th>
						<th>JobExecution Count</th>
						<th>Last JobExecution</th>
						<th>Parameters</th>
					</tr>
				</thead>
				<tbody>
					<#list jobInstances as jobInstanceInfo>
						<#if jobInstanceInfo_index % 2 == 0>
							<#assign rowClass="name-sublevel1-even"/>
						<#else>
							<#assign rowClass="name-sublevel1-odd"/>
						</#if>
						<#assign executions_url><@spring.url relativeUrl="${servletPath}/jobs/${job.name}/${jobInstanceInfo.id?c}/executions"/></#assign>
						<tr class="${rowClass}">
							<td>${jobInstanceInfo.id}</td>
							<td><a href="${executions_url}">executions</a></td>
							<td>${jobInstanceInfo.jobExecutionCount}</td>
							<#if jobInstanceInfo.lastJobExecution??>
								<#assign execution_url><@spring.url relativeUrl="${servletPath}/jobs/executions/${jobInstanceInfo.lastJobExecution.id?c}"/></#assign>
								<td><a href="${execution_url}">${jobInstanceInfo.lastJobExecution.status}</a></td>
							<#else>
								<td>?</td>							
							</#if>
							<td>${jobInstanceInfo.jobInstance.jobParameters}</td>
						</tr>
					</#list>
				</tbody>
			</table>
			<ul class="controlLinks">
				<li>Rows: ${startJobInstance}-${endJobInstance} of ${totalJobInstances}</li> 
				<#assign job_url><@spring.url relativeUrl="${servletPath}/jobs/${job.name}"/></#assign>
				<#if nextJobInstance??><li><a href="${job_url}?startJobInstance=${nextJobInstance?c}&pageSize=${pageSize!20}">Next</a></li></#if>
				<#if previousJobInstance??><li><a href="${job_url}?startJobInstance=${previousJobInstance?c}&pageSize=${pageSize!20}">Previous</a></li></#if>
				<!-- TODO: enable pageSize editing -->
				<li>Page Size: ${pageSize!20}</li>
			</ul>
	
			<p>The table above shows instances of this job with an indication of the status of the last execution.  
			If you want to look at all executions for <a href="${executions_url}">see here</a>.</p>
	
	<#else>
		<#if jobName??>
			<@spring.bind path="jobName" />
			<@spring.showErrors separator="<br/>" classOrStyle="error" /><br/>
		<#else>
			<p>There are no job instances for this job.</p>
		</#if>
	</#if>
	
</div><!-- jobs -->
