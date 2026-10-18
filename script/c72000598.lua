--变形斗士·“是什么呢？”
local s,id,o=GetID()
function s.initial_effect(c)
	--activate
	local e0=Effect.CreateEffect(c)
	e0:SetCategory(CATEGORY_TODECK)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e0:SetOperation(s.activate)
	c:RegisterEffect(e0)
	--declare card name
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ANNOUNCE+CATEGORY_SPECIAL_SUMMON+CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_FZONE)
	e1:SetCountLimit(1,id+o)
	e1:SetTarget(s.fktg)
	e1:SetOperation(s.fkop)
	c:RegisterEffect(e1)
	--change position
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_FZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1)
	e2:SetTarget(s.postg)
	e2:SetOperation(s.posop)
	c:RegisterEffect(e2)
end
function s.tdfilter(c)
	return c:IsFaceupEx() and c:IsType(TYPE_MONSTER) and c:IsSetCard(0x26) and c:IsAbleToDeck()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local cg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_REMOVED,0,nil,e,tp)
	if #cg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local sg=cg:Select(tp,1,1,nil)
		Duel.SendtoDeck(sg,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end
function s.fktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,nil)
		return g:GetClassCount(Card.GetCode)>=5
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
	local ac=Duel.AnnounceCard(tp)
	Duel.SetTargetParam(ac)
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,0)
end
function s.samecode(c,sg)
	return not sg:IsExists(Card.IsCode,1,nil,c:GetCode())
end
function s.fkop(e,tp,eg,ep,ev,re,r,rp)
	local ac=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	local mg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,nil)
	local scg=mg:Filter(Card.IsCode,nil,ac)
	if scg:GetCount()==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local sg=scg:Select(tp,1,1,nil)
	local mg2=mg:Filter(s.samecode,nil,sg)
	while sg:GetCount()<5 and mg2:GetCount()>0 do
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
		local tc=mg2:Select(tp,1,1,nil):GetFirst()
		sg:AddCard(tc)
		mg2=mg:Filter(s.samecode,nil,sg)
	end
	if sg:GetCount()<5 then return end
	Duel.ConfirmCards(1-tp,sg)
	local rc=sg:RandomSelect(1-tp,1):GetFirst()
	if rc and rc:IsCode(ac) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		if rc:IsType(TYPE_MONSTER) and rc:IsCanBeSpecialSummoned(e,0,tp,false,false) then
			Duel.SpecialSummon(rc,0,tp,tp,false,false,POS_FACEUP)
		elseif rc:IsType(TYPE_SPELL+TYPE_TRAP) and rc:IsSSetable() then
			Duel.SSet(tp,rc)
		end
	end
end
function s.posfilter(c)
	return c:IsFaceup() and c:IsCanChangePosition()
end
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.posfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSITION)
	local g=Duel.SelectTarget(tp,s.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEDOWN_ATTACK)
	end
end
