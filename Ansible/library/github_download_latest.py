#!/usr/bin/python

from ansible.module_utils.basic import AnsibleModule
import requests
import pprint
import re

GITHUB_API_URL = "https://api.github.com/repos/"

def __get_matching_url(module):
    asset_list = requests.get(GITHUB_API_URL + module.params['github_path'] + "/releases/latest").json()["assets"]
    file_regex = re.compile(module.params['file_regex'])
    download_urls = [asset["browser_download_url"] for asset in asset_list]
    
    # Deduplicate and return list of matches. Order does not matter since it should only return 1 match
    return list(set(filter(file_regex.match, download_urls))) 

def run_module():
    module_args = dict(
        github_path = dict(type='str', required=True),
        file_regex = dict(type='str', required=True)
    )

    result = dict(
        changed = False,
        url = ''
    )

    module = AnsibleModule(
        argument_spec=module_args,
        supports_check_mode=False
    )

    matched_urls = __get_matching_url(module)

    if len(matched_urls) > 1:
        result["url"] = matched_urls
        module.fail_json(msg="File regex matched more than 1 file", **result)
    elif len(matched_urls) < 1:
        module.fail_json(msg="File regex returned no files", **result)

    result["url"] = matched_urls[0]
    result['changed'] = False # This is a purely informational module
    module.exit_json(**result)

def main():
    run_module()

if __name__ == '__main__':
    main()