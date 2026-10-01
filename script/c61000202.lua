--魔毒之祸津大蛇
local s,id,o=GetID()
function s.initial_effect(c)
	--link summon
	aux.AddLinkProcedure(c,nil,2,3,s.lcheck)
	c:EnableReviveLimit()
	--change name
	aux.EnableChangeCode(c,61000203,LOCATION_MZONE+LOCATION_GRAVE)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCondition(s.condition)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_MATERIAL_CHECK)
	e3:SetValue(s.valcheck)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SSET)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(s.setcon)
	e4:SetTarget(s.settg)
	e4:SetOperation(s.setop)
	c:RegisterEffect(e4)
end
function s.mfilter(c)
	return c:IsLinkRace(RACE_ZOMBIE) and c:IsLinkType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_RITUAL)
end
function s.lcheck(g,lc)
	return g:IsExists(s.mfilter,1,nil)
end
function s.nsfilter(c)
	return not (c:IsSummonLocation(LOCATION_EXTRA) or c:IsSummonType(SUMMON_TYPE_RITUAL))
end
function s.valcheck(e,c)
	local g=c:GetMaterial()
	if g:GetCount()~=0 and not g:IsExists(s.nsfilter,1,nil) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK) and e:GetLabel()==1
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e1:SetCountLimit(1)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,3))
end
function s.colfilter(c,e)
	if not (c:IsLocation(LOCATION_MZONE) and c:IsType(TYPE_MONSTER)) then return false end
	-- there're bugs in IsAllColumn, when the column is full, it returns false
	if c:GetSequence()>=5 then
		return c:GetColumnGroupCount()==4
	end
	return c:IsAttackAbove(2500) and c:IsRace(RACE_ZOMBIE) and c:GetColumnGroup():GetCount()>0 and c:IsReleasableByEffect(e)
end
function s.zonefilter(c)
	return c:GetSequence()<5
end
function s.fullmzone(p)
	return Duel.GetMatchingGroup(s.zonefilter,p,LOCATION_MZONE,0,nil):GetCount()==5
end
function s.fullszone(p)
	return Duel.GetMatchingGroup(s.zonefilter,p,LOCATION_SZONE,0,nil):GetCount()==5
end
function s.canrow(p)
	return (s.fullmzone(p) or s.fullszone(p)) and Duel.IsPlayerCanDraw(p,2)
end
function s.rowdesgroup(p)
	local g=Group.CreateGroup()
	if s.fullmzone(p) then
		g:Merge(Duel.GetMatchingGroup(s.zonefilter,p,LOCATION_MZONE,0,nil))
	end
	if s.fullszone(p) then
		g:Merge(Duel.GetMatchingGroup(s.zonefilter,p,LOCATION_SZONE,0,nil))
	end
	return g
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.colfilter,tp,LOCATION_MZONE,0,1,nil,e) end
	e:GetHandler():RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,4))
	local g=Group.CreateGroup()
	local rg=Duel.GetMatchingGroup(s.colfilter,tp,LOCATION_MZONE,0,nil,e)
	for tc in aux.Next(rg) do
		g:Merge(tc:GetColumnGroup())
		g:AddCard(tc)
	end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectMatchingCard(tp,s.colfilter,tp,LOCATION_MZONE,0,1,6,nil,e)
	if g:GetCount()==0 then return end
	Duel.HintSelection(g)
	local sg=Group.CreateGroup()
	for tc in aux.Next(g) do
		local dg=tc:GetColumnGroup()
		sg:Merge(dg)
	end
	if Duel.Release(g,REASON_EFFECT)~=0 then
		Duel.Destroy(sg,REASON_EFFECT)
	end
end
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
function s.setfilter(c)
	return aux.IsCodeListed(c,61000203) and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		Duel.SSet(tp,tc)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,5))
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		if tc:IsType(TYPE_SPELL) then
			e1:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
		else
			e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
		end
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end