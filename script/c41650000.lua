-- 羽隙之光彩，因白鸟心愿而相聚
local s,id,o=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--huishou
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
function s.filter(c,e,tp,m)
	if bit.band(c:GetType(),0x81)~=0x81
		or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true) or not c:IsSetCard(0xe90) or not c:IsFaceupEx() then return false end
	if c.mat_filter then
		m=m:Filter(c.mat_filter,nil,tp)
	end
	return m:CheckWithSumEqual(Card.GetRitualLevel,c:GetLevel(),1,99,c)
end
function s.matfilter(c)
	return c:IsType(TYPE_NORMAL) and c:IsReleasable() and c:IsFaceupEx()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
		local mg=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,nil)
		return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND+LOCATION_EXTRA,0,1,nil,e,tp,mg)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.fselect(g,mc)
	return g:GetClassCount(Card.GetOriginalAttribute)==g:GetCount() and g:CheckWithSumEqual(Card.GetRitualLevel,mc:GetLevel(),g:GetCount(),g:GetCount(),mc)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	::cancel::
	local mg=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tg=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND+LOCATION_EXTRA,0,1,1,nil,e,tp,mg)
	if tg:GetCount()>0 then
		local tc=tg:GetFirst()
		if tc.mat_filter then
			mg=mg:Filter(tc.mat_filter,nil,tp)
		end
		local lv=tc:GetLevel()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		aux.GCheckAdditional=function(sg) return sg:GetSum(Card.GetRitualLevel,tc)<=lv end
		local mat=mg:SelectSubGroup(tp,s.fselect,true,1,99,tc,lv)
		aux.GCheckAdditional=nil
		if not mat then goto cancel end
		tc:SetMaterial(mat)
		Duel.Release(mat,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
		Duel.BreakEffect()
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
function s.thrfilter(c,tp)
	return c:IsType(TYPE_RITUAL) and c:IsType(TYPE_MONSTER) and c:IsPreviousControler(tp)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and eg:IsExists(s.thrfilter,1,nil,tp)
end
function s.tdfilter(c,b1,b2)
	return c:IsType(TYPE_NORMAL) and ((b1 and c:IsAbleToHand()) or (b2 and c:IsAbleToDeck()))
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local b1,b2=c:IsAbleToDeck(),c:IsAbleToHand()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tdfilter(chkc,b1,b2) end
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE,0,1,nil,b1,b2) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil,b1,b2)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		local g=Group.FromCards(tc,c)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local tg=g:FilterSelect(tp,Card.IsAbleToHand,1,1,nil)
		g:Sub(tg)
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tg:GetFirst())
		Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	end
end

