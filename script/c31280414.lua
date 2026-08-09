--破壞灾谕 逐光之奏绝
local s,id,o=GetID()
function s.initial_effect(c)
	--发动
	local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--连接召唤   
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o*10000)
    e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.lktg)
	e2:SetOperation(s.lkop)
	c:RegisterEffect(e2)
end
function s.desfilter(c)
	return (c:IsSetCard(0x3ca1) or c:IsType(TYPE_PENDULUM)) and c:GetOriginalType()&TYPE_MONSTER>0
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x3ca1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
    	and (c:IsFaceup() or not c:IsLocation(LOCATION_EXTRA))
        and ((c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0)
        or (c:IsLocation(LOCATION_GRAVE+LOCATION_HAND) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0))
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsOnField() and s.desfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,LOCATION_ONFIELD,0,1,nil)
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE+LOCATION_HAND+LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
    if g:GetFirst():IsFacedown() then Duel.ConfirmCards(1-tp,g) end    	
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_HAND+LOCATION_EXTRA,0,1,1,nil,e,tp)
    if Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 and tc:IsRelateToEffect(e) then
    	Duel.Destroy(tc,REASON_EFFECT)	
	end
end
function s.lkfilter(c,mg)
	return mg:CheckSubGroup(s.fselect,1,mg:GetCount(),c)
end
function s.fselect(g,sc)
	return g:IsExists(Card.IsSetCard,1,nil,0x3ca1) and sc:IsLinkSummonable(g,nil,g:GetCount(),g:GetCount())
end
function s.lktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local mg=Duel.GetMatchingGroup(nil,tp,LOCATION_MZONE,0,nil)
	if chk==0 then return Duel.IsExistingMatchingCard(s.lkfilter,tp,LOCATION_EXTRA,0,1,nil,mg) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.lkop(e,tp,eg,ep,ev,re,r,rp)
	local mg=Duel.GetMatchingGroup(nil,tp,LOCATION_MZONE,0,nil)
	local lg=Duel.GetMatchingGroup(s.lkfilter,tp,LOCATION_EXTRA,0,nil,mg)
	if lg:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local lc=lg:Select(tp,1,1,nil):GetFirst()
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LMATERIAL)
		local sg=mg:SelectSubGroup(tp,s.fselect,false,1,mg:GetCount(),lc)
		Duel.LinkSummon(tp,lc,sg)
	end
end