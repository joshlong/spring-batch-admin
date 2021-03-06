/*
 * Copyright 2009-2010 the original author or authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.springframework.batch.admin.web.views;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.batch.admin.web.util.ResourceInfo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;
import org.springframework.test.context.support.WebApplicationContextLoader;
import org.springframework.validation.BindException;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.servlet.View;

@ContextConfiguration(loader = WebApplicationContextLoader.class, inheritLocations = false, locations = { "AbstractResourceViewTests-context.xml" })
@RunWith(SpringJUnit4ClassRunner.class)
public class HomeJsonViewTests extends AbstractResourceViewTests {

	private final HashMap<String, Object> model = new HashMap<String, Object>();

	@Autowired
	@Qualifier("home.json")
	private View standard;

	@Test
	public void testDefaultJsonView() throws Exception {
		List<ResourceInfo> resources = new ArrayList<ResourceInfo>();
		resources.add(new ResourceInfo("/local", RequestMethod.GET));
		resources.add(new ResourceInfo("/jobs/{jobName}.json", RequestMethod.GET, "foo"));
		model.put("resources", resources);
		model.put("baseUrl", "http://localhost:8080/springsource");
		standard.render(model, request, response);
		String content = response.getContentAsString();
		// System.err.println(content);
		assertTrue(content.contains("\"http://localhost:8080/springsource/batch/jobs/{jobName}.json\""));
		JsonWrapper wrapper = new JsonWrapper(content);
		assertEquals(2, wrapper.get("feed.resources", Map.class).size());
		assertEquals("foo", wrapper.get("feed.resources['/jobs/{jobName}'].description"));
		assertEquals("The local resource description", wrapper.get("feed.resources['/local'].description"));
	}

	@Test
	public void testErrorsJsonView() throws Exception {
		BindException errors = new BindException(new Object(), "baseUrl");
		errors.reject("no.resources", "No Resources");
		model.put("errors", errors);
		model.put("baseUrl", "http://localhost:8080/springsource");
		standard.render(model, request, response);
		String content = response.getContentAsString();
		// System.err.println(content);
		JsonWrapper wrapper = new JsonWrapper(content);
		assertEquals(0, wrapper.get("feed.resources", Map.class).size());
		assertEquals("No Resources", wrapper.get("errors['no.resources']"));
	}

	@Test
	public void testEmptyJsonView() throws Exception {
		model.put("baseUrl", "http://localhost:8080/springsource");
		standard.render(model, request, response);
		String content = response.getContentAsString();
		// System.err.println(content);
		JsonWrapper wrapper = new JsonWrapper(content);
		assertEquals(0, wrapper.get("feed.resources", Map.class).size());
	}

}
