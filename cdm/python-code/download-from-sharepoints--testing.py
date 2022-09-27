import os
from office365.runtime.auth.user_credential import UserCredential
from office365.sharepoint.client_context import ClientContext

site_url = "https://avenzacorp.sharepoint.com/sites/BAS/"

file_path="/sites/BAS/Shared Documents/4.CDM/data-requirements/cdm__quarterly_data.csv"

report_folder__cdm = 'c:/cdm/'
download_folder = report_folder__cdm

file_name = 'cdm__quarterly_data.csv'
download_to = os.path.join(download_folder, file_name)

ctx = ClientContext(site_url).with_credentials(UserCredential('nhoang@syangie.com', 'Ibethere4u@188'))

_file = open(download_to, "wb")

ctx.web.get_file_by_server_relative_path(file_path).download(
        _file
    ).execute_query()

print(f"====Downloaded Source File for {file_name}====")

_file.close()
