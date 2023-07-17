import React from "react";

import { ColumnFilterValue } from "@coreui/react-pro/src/components/smart-table/types";
import { useNavigate } from "react-router";

import { ContentProps } from "../../../Controllers/ContentController/ContentApi";
import { capitalizeWord } from "../../../utils/commonUtils";
import TableComponent from "../../common/TableComponent/TableComponent";
import {
  contentColumns,
  stateColumnBadge,
} from "../../common/TableComponent/TableComponentHelperFunctions";

import styles from "./contentTableComponents.module.scss";

interface ContentTableComponentProps {
  tableData: Array<ContentProps>;
  pagination: {
    limit: number;
    offset: number;
    orderBy: string;
    type?: string | undefined;
    filter: ColumnFilterValue;
  };
  setPagination: React.Dispatch<
    React.SetStateAction<{
      limit: number;
      offset: number;
      orderBy: string;
      type?: string | undefined;
      filter: ColumnFilterValue;
    }>
  >;
}

const ContentTableComponent: React.FC<ContentTableComponentProps> = ({
  tableData,
  pagination,
  setPagination,
}: ContentTableComponentProps) => {
  const navigate = useNavigate();

  const columnProps = {
    subject: (content: ContentProps): JSX.Element => (
      <td>{capitalizeWord(content.subject)}</td>
    ),
    state: (content: { state: string }): JSX.Element =>
      stateColumnBadge(content.state),
    actions: (content: ContentProps): JSX.Element => (
      <td>
        <div
          className={styles.buttonStyle}
          onClick={() => {
            navigate(`/news/${content.id}`, {
              state: { newsContent: content },
            });
          }}
        >
          Show
        </div>
      </td>
    ),
  };

  const renderDataTable = (): JSX.Element => (
    <>
      <TableComponent
        tableData={tableData}
        tableColumnProps={columnProps}
        tableColumnsVisibility={contentColumns}
        pagination={pagination}
        setPagination={setPagination}
      />
    </>
  );

  return <div>{renderDataTable()}</div>;
};

export default ContentTableComponent;
