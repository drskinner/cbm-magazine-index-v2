module Api
  class ArticlesByAuthorQuery
    def self.call(author:)
      sql = <<~ENDSQL
        SELECT
          a.id,
          a.title,
          a.author,
          a.description,
          a.page,
          a.archive_page,
          i.id AS issue_id,
          i.month AS month,
          TO_CHAR(
            TO_DATE (i.month::text, 'MM'), 'Month'
          ) AS month_name,
          i.year,
          i.sequence,
          m.name AS magazine_name,
          m.slug AS magazine_slug,
          m.archive_suffix AS archive_suffix
        FROM
          articles a
        INNER JOIN
          issues i ON (i.id = a.issue_id)
        INNER JOIN
          magazines m ON (m.id = i.magazine_id)
        WHERE
          a.author = #{sanitize_param(author)}
        ORDER BY
          i.year ASC, i.month ASC, a.page ASC;
      ENDSQL

      result = ActiveRecord::Base.connection.execute(sql)
    end

    private

    def self.sanitize_param(param)
      ActiveRecord::Base.connection.quote(param)
    end
  end
end
