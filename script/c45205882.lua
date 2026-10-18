--烧心宇宙
local s,id=GetID()
function s.initial_effect(c)
	--场地魔法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)

	--① 这张卡在场上表侧表示存在的场合。自己受到的效果伤害由对方代受。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_REFLECT_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTargetRange(1,0)
	e1:SetValue(s.refval)
	c:RegisterEffect(e1)

	--② 自己·对方的回合结束阶段发动。这张卡以外的双方场上的卡全部送去墓地。那之后，恢复双方8000基本分。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,id+100)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
end

-- ① 反射伤害：只反射效果伤害
function s.refval(e,re,r,rp)
	if bit.band(r,REASON_EFFECT)~=0 then return true end
	return false
end

-- ② target
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_ONFIELD+LOCATION_FZONE,LOCATION_ONFIELD+LOCATION_FZONE,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,g:GetCount(),0,0)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,0,8000)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,1,8000)
end

-- ② 送墓过滤：这张卡以外
function s.tgfilter(c,ec)
	return c~=ec
end

-- ② 处理
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_ONFIELD+LOCATION_FZONE,LOCATION_ONFIELD+LOCATION_FZONE,c)
	if g:GetCount()>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
	Duel.BreakEffect()
	Duel.Recover(0,8000,REASON_EFFECT)
	Duel.Recover(1,8000,REASON_EFFECT)
end

return s
