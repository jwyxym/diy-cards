--升阶魔法 七皇跃升
function c38030145.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,38030145+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c38030145.target)
	e1:SetOperation(c38030145.activate)
	c:RegisterEffect(e1)
end
function c38030145.tfilter(c,e,tp)
	local no=aux.GetXyzNumber(c)
	return c:IsSetCard(0x48) and c:IsFaceup() and no and no>=101 and no<=107-- and not c:IsSetCard(0x1048)
		and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
		and Duel.IsExistingMatchingCard(c38030145.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,c:GetRank()+1,no)
end
function c38030145.spfilter(c,e,tp,mc,rk,no)
	return aux.GetXyzNumber(c)==no and c:IsSetCard(0x1048) and mc:IsCanBeXyzMaterial(c)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
function c38030145.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c38030145.tfilter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(c38030145.tfilter,tp,LOCATION_MZONE,0,1,nil,e,tp)end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,c38030145.tfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function c38030145.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local no=aux.GetXyzNumber(tc)
	if not aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL)
		or tc:IsFacedown() or not tc:IsRelateToChain() or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) or not no then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,c38030145.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,tc:GetRank()+1,no):GetFirst()
	if sc then
		local mg=tc:GetOverlayGroup()
		if mg:GetCount()~=0 then
			Duel.Overlay(sc,mg)
		end
		sc:SetMaterial(Group.FromCards(tc))
		Duel.Overlay(sc,Group.FromCards(tc))
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
		--
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,sc):Filter(Card.IsCanOverlay,nil)
		if #g==0 or not Duel.SelectYesNo(tp,aux.Stringid(38030145,2)) then return end
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
		local sg=g:Select(tp,1,1,nil)
		Duel.HintSelection(sg)
		if sg:GetFirst():IsImmuneToEffect(e) then return end
		Duel.Overlay(sc,sg)
	end
end
