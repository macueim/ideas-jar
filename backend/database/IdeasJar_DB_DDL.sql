create table public.ideas (
  id integer primary key not null default nextval('ideas_id_seq'::regclass),
  content text not null,
  is_voice boolean default false,
  priority priority_enum default 'medium'::priority_enum,
  improved_text text,
  created_at timestamp with time zone default CURRENT_TIMESTAMP,
  updated_at timestamp with time zone default CURRENT_TIMESTAMP
);
create index idx_ideas_created_at on ideas using btree (created_at);
create index idx_ideas_priority on ideas using btree (priority);
create index idx_ideas_content_search on ideas using gin ((to_tsvector('english'::regconfig));

