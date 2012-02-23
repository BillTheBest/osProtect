<div class="flashes">
  <% flash.each do |name, msg| %>
    <%= content_tag :div, msg, :class=>"flash flash_#{name}" %>
  <% end %>
</div>
<div id="osprotect_content" class="without_sidebar">
  <div id="main_content_wrapper">
    <div id="main_content">
      <table border="0" cellspacing="0" cellpadding="0" class="dashboard">
        <tbody>
          <tr>
            <td>
              <div class="dashboard_section panel">
                <div id="panel_header" style="margin-top:-26px">
                  <ul class="tabbed_navigation" id="panel_tabs">
                    <li><%= link_to 'Today', pulse_path %></li>
                    <li><%= link_to 'Last 24 Hours', pulse_path(range: 'last_24') %></li>
                    <li><%= link_to 'This Week', pulse_path(range: 'week') %></li>
                    <li><%= link_to 'Last Week', pulse_path(range: 'last_week') %></li>
                    <li><%= link_to 'This Month', pulse_path(range: 'month') %></li>
                    <li><%= link_to 'Past Year', pulse_path(range: 'past_year') %></li>
                    <li><%= link_to 'Year', pulse_path(range: 'year') %></li>
                  </ul>
                </div>
                <div class="panel_contents">
                  <h3>
                    <%= params[:range].to_s.titleize %>:&nbsp;&nbsp;
                    <%= @start_time.utc.strftime("%a %b %d, %Y %I:%M:%S %P %Z") %>
                    &nbsp;&nbsp;-&nbsp;&nbsp;
                    <%= @end_time.utc.strftime("%a %b %d, %Y %I:%M:%S %P %Z") %>
                  </h3>

                  <h3 style="clear: both; text-align:center; font-size:15px">Top Attackers</h3>
                  <% if @attackers.blank? %>
                      <h3>none</h3>
                  <% else
                      @attackers = @attackers.order('ipcnt DESC')
                      total = 0
                      data = []
                      labels = []
                      @attackers.collect do |attack_ip|
                        total += attack_ip.ipcnt
                        data << attack_ip.ipcnt
                      end
                      labels = @attackers.collect do |attack_ip|
                        "#{attack_ip.ip_source}"
                      end
                      %>
                      <div class="pulse_chart_data_wrapper">
                        <div class="pulse_chart" style="float:left">
                          <%= image_tag(Gchart.pie_3d(data: data, labels: labels, size: '450x250', title: "Top Attackers", theme: :thirty7signals)) %>
                          <canvas id="chartCanvasTopAttackers" width="850" height="440" style="background:#fff">
                              Your web-browser does not support the HTML 5 canvas element.
                          </canvas>
                          <script type="application/javascript">
                            var chartTopAttackers = new AwesomeChart('chartCanvasTopAttackers');
                            chartTopAttackers.chartType = "pareto";
                            // chartTopAttackers.chartType = "default"; // vertical bars
                            // chartTopAttackers.chartType = "pie";
                            // chartTopAttackers.chartType = "doughnut";
                            // chartTopAttackers.chartType = "exploded pie";
                            // chartTopAttackers.chartType = "horizontal bars";
                            // chartTopAttackers.title = "Top Attackers";
                            chartTopAttackers.title = "   ";
                            chartTopAttackers.data = [<%=data.join(',')%>];
                            chartTopAttackers.labels = ['<%=labels.join("', '")%>'];
                            chartTopAttackers.randomColors = true;
                            chartTopAttackers.draw();
                          </script>
                        </div>
                        <div class="pulse_data" style="float:right">
                          <table border="0" cellspacing="0" cellpadding="0">
                            <thead>
                              <tr>
                                <th style="text-align:right"><small>count</small></th>
                                <th style="text-align:left">Top Attackers <small>(source IPs)</small></th>
                              </tr>
                            </thead>
                            <tbody>
                              <% @attackers.each do |attack_ip| %>
                                  <tr class="<%= cycle('even', 'odd') %>">
                                    <td align="right"><%= number_with_delimiter(attack_ip.ipcnt) %></td>
                                    <td><%= link_to attack_ip.ip_source, events_path('q[source_address]' => attack_ip.ip_source) %></td>
                                  </tr>
                              <% end %>
                            </tbody>
                          </table>
                        </div>
                      </div>
                  <% end %>
                  <hr style="clear: both; margin-bottom:30px; height:5px" />

                  <h3 style="clear: both; text-align:center; font-size:15px">Top Targets</h3>
                  <% if @targets.blank? %>
                      <h3>none</h3>
                  <% else 
                      total = 0
                      data = []
                      labels = []
                      @targets.collect do |target_ip|
                        total += target_ip.ipcnt
                        data << target_ip.ipcnt
                      end
                      labels = @targets.collect do |target_ip|
                        "#{target_ip.ip_destination}"
                      end
                      %>
                      <div class="pulse_chart_data_wrapper">
                        <div class="pulse_chart" style="float:left">
                          <%#= image_tag(Gchart.pie(data: data, labels: labels, size: '450x250', title: "Top Targets", theme: :thirty7signals)) %>
                          <canvas id="chartCanvasTopTargets" width="850" height="440" style="background:#fff">
                              Your web-browser does not support the HTML 5 canvas element.
                          </canvas>
                          <script type="application/javascript">
                            var chartTopTargets = new AwesomeChart('chartCanvasTopTargets');
                            chartTopTargets.chartType = "pareto";
                            // chartTopTargets.title = "Top Targets";
                            chartTopTargets.title = "  ";
                            chartTopTargets.data = [<%=data.join(',')%>];
                            chartTopTargets.labels = ['<%=labels.join("', '")%>'];
                            chartTopTargets.randomColors = true;
                            chartTopTargets.draw();
                          </script>
                        </div>
                        <div class="pulse_data" style="float:right">
                          <table border="0" cellspacing="0" cellpadding="0">
                            <thead>
                              <tr>
                                <th style="text-align:left"><small>count</small></th>
                                <th style="text-align:left">Top Targets <small>(destination IPs)</small></th>
                              </tr>
                            </thead>
                            <tbody>
                              <% @targets.order('ipcnt DESC').each do |target_ip| %>
                                  <tr class="<%= cycle('even', 'odd') %>">
                                    <td align="right"><%= number_with_delimiter(target_ip.ipcnt) %></td>
                                    <td><%= link_to target_ip.ip_destination, events_path('q[destination_address]' => target_ip.ip_destination) %></td>
                                  </tr>
                              <% end %>
                            </tbody>
                          </table>
                        </div>
                      </div>
                  <% end %>
                  <hr style="clear: both; margin-bottom:20px; height:5px" />

                  <h3 style="text-align:center; font-size:15px">Priorities</h3>
                  <% if @priorities.blank? %>
                      <h3>none</h3>
                  <% else 
                      total = 0
                      data = []
                      labels = []
                      @priorities.collect do |priority|
                        total += priority.priority_cnt
                        data << priority.priority_cnt
                      end
                      labels = @priorities.collect do |priority|
                        # "priority #{priority.sig_priority} (#{total == 0 ? 0 : (100.0 * priority.priority_cnt / total).round(2)}%)"
                        "priority #{priority.sig_priority}"
                      end
                      %>
                      <div class="pulse_chart_data_wrapper">
                        <div class="pulse_chart" style="float:left">
                          <%#= image_tag(Gchart.pie(data: data, labels: labels, size: '400x200', title: "Priority (googlecharts)", theme: :thirty7signals)) %>
                          <canvas id="chartCanvasPriority" width="850" height="440" style="background:#fff">
                              Your web-browser does not support the HTML 5 canvas element.
                          </canvas>
                          <script type="application/javascript">
                            var chartPriority = new AwesomeChart('chartCanvasPriority');
                            chartPriority.chartType = "pareto";
                            // chartPriority.chartType = "default"; // vertical bars
                            // chartPriority.chartType = "pie";
                            // chartPriority.chartType = "doughnut";
                            // chartPriority.chartType = "exploded pie";
                            // chartPriority.chartType = "horizontal bars";
                            // chartPriority.title = "Priorities";
                            chartPriority.title = "   ";
                            chartPriority.data = [<%=data.join(',')%>];
                            chartPriority.labels = ['<%=labels.join("', '")%>'];
                            chartPriority.randomColors = true;
                            chartPriority.draw();
                          </script>
                        </div>
                        <div class="pulse_data" style="float:right">
                          <table border="0" cellspacing="0" cellpadding="0">
                            <thead>
                              <tr>
                                <th style="text-align:left"><small>count</small></th>
                                <th style="text-align:left">Priority</th>
                              </tr>
                            </thead>
                            <tbody>
                              <% @priorities.each do |priority| %>
                                  <tr class="<%= cycle('even', 'odd') %>">
                                    <td align="right"><%= number_with_delimiter(priority.priority_cnt) %></td>
                                    <td align="left"><%= link_to priority.sig_priority, events_path('q[sig_priority]' => priority.sig_priority) %></td>
                                  </tr>
                              <% end %>
                            </tbody>
                          </table>
                        </div>
                      </div>
                  <% end %>
                  <hr style="clear: both; margin-bottom:30px; height:5px" />

                  <h3 style="clear: both; text-align:center; font-size:15px">Top Events by Signature</h3>
                  <% if @events.blank? %>
                      <h3>none</h3>
                  <% else 
                      total = 0
                      data = []
                      labels = []
                      @events.collect do |event|
                        total += event.event_cnt
                        data << event.event_cnt
                      end
                      labels = @events.collect do |event|
                        "#{event.sig_name} (#{total == 0 ? 0 : (100.0 * event.event_cnt / total).round(2)}%)"
                      end
                      %>
                      <%#= image_tag(Gchart.pie(data: data, labels: labels, size: '850x250', title: "Top Events by Signature", theme: :thirty7signals)) %>
                      <!-- <canvas id="chartCanvasTopEventsBySignature" width="850" height="440" style="background:#fff">
                          Your web-browser does not support the HTML 5 canvas element.
                      </canvas>
                      <script type="application/javascript">
                        var chartTopEventsBySignature = new AwesomeChart('chartCanvasTopEventsBySignature');
                        chartTopEventsBySignature.chartType = "horizontal bars";
                        chartTopEventsBySignature.title = "Top Events by Signature";
                        chartTopEventsBySignature.data = [<%=data.join(',')%>];
                        chartTopEventsBySignature.labels = ['<%=labels.join("', '")%>'];
                        chartTopEventsBySignature.randomColors = true;
                        chartTopEventsBySignature.draw();
                      </script> -->
                      <table border="0" cellspacing="0" cellpadding="0">
                        <thead>
                          <tr>
                            <th style="text-align:right"><small>count</small></th>
                            <th style="text-align:left">Top Events by Signature</th>
                          </tr>
                        </thead>
                        <tbody>
                          <% @events.each do |event| %>
                              <tr class="<%= cycle('even', 'odd') %>">
                                <td align="right">
                                  <%= "#{total == 0 ? 0 : (100.0 * event.event_cnt / total).round(2)}%" %>
                                  &nbsp;&nbsp;&nbsp;&nbsp;
                                  <%= number_with_delimiter(event.event_cnt) %>
                                </td>
                                <td><%= link_to event.sig_name, events_path('q[sig_id]' => event.sig_id) %></td>
                              </tr>
                          <% end %>
                        </tbody>
                      </table>
                  <% end %>
                  <hr style="clear: both; margin-bottom:30px; height:5px" />

                  <h3 style="clear: both; text-align:center; font-size:15px">Most Active Times</h3>
                  <% if @hot_times.blank? %>
                      <h3>none</h3>
                  <% else 
                      total = 0
                      data = []
                      labels = []
                      @hot_times.collect do |hot_time|
                        total += hot_time.cnt
                        data << hot_time.cnt
                      end
                      labels = @hot_times.collect do |hot_time|
                        s = hot_time.minute
                        e = hot_time.minute + 15.minutes
                        "#{s.strftime("%l:%M")}-#{e.strftime("%l:%M %P")} (#{total == 0 ? 0 : (100.0 * hot_time.cnt / total).round}%)"
                      end
                      %>
                      <%#
                      // note: the image_tag will be a broken image if the user's browser doesn't have internet access, so we 
                      //       use the following jquery code to fix that:
                      $(window).bind('load', function() {
                        $('img').each(function() {
                          if((typeof this.naturalWidth != "undefined" && this.naturalWidth == 0 ) || this.readyState == 'uninitialized' ) {
                            $(this).attr('src', 'missing.jpg');
                          }
                        });
                      })
                      %>
                      <%#= image_tag(Gchart.pie_3d(data: data, labels: labels, size: '750x200', title: "Active Times", theme: :thirty7signals)) %>
                      <table border="0" cellspacing="0" cellpadding="0">
                        <thead>
                          <tr>
                            <th style="text-align:right"><small>count</small></th>
                            <th style="text-align:left">Most Active Times (UTC)</th>
                          </tr>
                        </thead>
                        <tbody>
                          <tr><td></td><td style="text-align:left"><small><em>15 minute intervals with more than 10 events</em></small></td></tr>
                          <% @hot_times.each do |hot_time| %>
                              <tr class="<%= cycle('even', 'odd') %>">
                                <%
                                  s = hot_time.minute
                                  e = hot_time.minute + 15.minutes
                                  case hot_time.cnt
                                    when 0..50; c = "black"; w = "normal"
                                    when 51..99; c = "orange"; w = "normal"
                                    else; c = "red"; w = "bold"
                                  end                                
                                %>
                                <td width="10%" align="right" style="color:<%=c%>; font-weight:<%=w%>"><%= number_with_delimiter(hot_time.cnt) %></td>
                                <td width="50%" style="color:<%=c%>; font-weight:<%=w%>"><%= s.strftime("%l:%M") %> - <%= e.strftime("%l:%M %P") %> </td>
                              </tr>
                          <% end %>
                        </tbody>
                      </table>
                  <% end %>
                  <hr style="clear: both; margin-bottom:30px; height:5px" />
                </div> <!-- panel_contents -->
              </div> <!-- dashboard_section -->
            </td>
          </tr>
        </tbody>
      </table>
    </div> <!-- main_content -->
  </div> <!-- main_content_wrapper -->
</div> <!-- osprotect_content -->