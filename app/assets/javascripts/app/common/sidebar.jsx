/** @jsx React.DOM */

var ApplicationToolsSidebar = React.createClass({
  render: function() {
    return (
      <div>
        <Grid>
          <Row>
            <Col xs={12}>
              <div className='sidebar-nav-container'>
                <SidebarNav style={{marginBottom: 0}}>
                  <SidebarNavItem glyph='icon-fontello-gauge' name='Dashboard' href='/app/dashboard' />
                  <SidebarNavItem glyph='icon-feather-mail' name={<span>Reporting </span>}>
                    <SidebarNav>
                      <SidebarNavItem glyph='icon-feather-inbox' name='Summary' href='/app/mailbox/inbox' />
                      <SidebarNavItem glyph='icon-outlined-mail-open' name='Commissions' href='/app/mailbox/mail' />
                    </SidebarNav>
                  </SidebarNavItem>
                  <SidebarNavItem href='/app/timeline' glyph='icon-ikons-time' name='Affiliate Links' />
                  <SidebarNavItem glyph='icon-pixelvicon-photo-gallery' name='Website Widget' href='/app/gallery' />
                  <SidebarNavItem glyph='icon-feather-share' name='Help' href='/app/social' />
                </SidebarNav>
              </div>
            </Col>
          </Row>
        </Grid>
        <hr style={{borderColor: '#3B4648', borderWidth: 2, marginTop: 15, marginBottom: 0, width: 200}} />
      </div>
    );
  }
});

var UserAvatarSidebarComponent = React.createClass({
  render: function() {
    return this.transferPropsTo(
      <div id='sidebar'>
        <div id='sidebar-container'>
          <Sidebar key={0} active>
            <ApplicationToolsSidebar />
          </Sidebar>
        </div>
      </div>
    );
  }
});

module.exports = UserAvatarSidebarComponent;
