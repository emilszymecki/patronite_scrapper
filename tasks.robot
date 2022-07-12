*** Settings ***
Documentation       Playwright template.

Library             RPA.Browser.Playwright    jsextension=${CURDIR}/module.js
Library             RPA.Tables
Library             RPA.FileSystem
Library             Collections


*** Tasks ***
Scrape Patronite
    Remove Old CSV
    Starting a browser with a page    https://patronite.pl/
    Accept GDPR
    Open Category From List


*** Keywords ***
Remove Old CSV
    Remove file    ${OUTPUT_DIR}${/}patronite.csv  

Starting a browser with a page
    [Arguments]    ${url}
    New Browser    chromium    headless=false
    New Context    viewport={'width': 1920, 'height': 1000}
    New Page    ${url}

Accept GDPR
    Wait For Elements State    .OK
    Click    text=Akceptuję i przechodzę do serwisu

Get Category List
    @{category_link_list}=    Evaluate JavaScript    body > div.footer > div > div > div:nth-child(1) a
    ...    (el) => el.map(x => x.href)
    ...    all_elements=True
    RETURN    ${category_link_list}

Get Members Value
    @{members_value}=    getMembersData
    RETURN    ${members_value}

Open Category From List
    ${category_link_list}=    Get Category List
    FOR    ${category}    IN    @{category_link_list}
        Log    ${category}
        Go To    ${category}
        Pagginate
    END

Pagginate
    ${next_btn}=    Get Element    .pagination__item >> text=Następne »
    ${next_count}=    Get Element Count    ${next_btn}
    WHILE    ${next_count} > 0
        Click    ${next_btn}
        Wait Until Network Is Idle    timeout=10s
        ${members_value}=    Get Members Value
        Save Rows CSV    ${members_value}
        ${next_count}=    Get Element Count    ${next_btn}
    END

Save Rows CSV
    [Arguments]    ${members_value}
    @{header_csv}=    Create List    tags    name    patrons    month_amount    total_amount
    ${file_exist}=    Does file exist    ${OUTPUT_DIR}${/}patronite.csv
    IF    ${file_exist}
        ${DT}=    Read table from CSV    ${OUTPUT_DIR}${/}patronite.csv    header=True    encoding=utf-8    dialect=excel
    ELSE
        ${DT}=    Create Table    columns=${header_csv}
    END

    FOR    ${member}    IN    @{members_value}
        &{dict_member}=    Convert To Dictionary    ${member}
        @{find_row}=    Find Table Rows    ${DT}    name    ==    ${dict_member}[name]
        ${exist_member}=    Evaluate    len($find_row) == 0
        IF    ${exist_member}
            Add table row    ${DT}    ${dict_member}
        END
    END
    Write table to CSV    ${DT}     ${OUTPUT_DIR}${/}patronite.csv    encoding=utf-8    dialect=excel
