--混沌No.103 神葬零娘 终葬
local s,id,o=GetID()

function s.initial_effect(c)
	aux.AddCodeList(c,94380860,20785975)
	aux.xyz_number[id]=103

	c:EnableReviveLimit()

	aux.AddXyzProcedureLevelFree(c,s.mfilter,s.xyzcheck,3,3)


	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_RANK_LEVEL_S)
	e0:SetValue(1)
	c:RegisterEffect(e0)

	-- ① 
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)

	-- ② 
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.spcon)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end

-- ======================================

function s.mfilter(c,xyzc)
	return c:IsFaceup()
		and c:IsAttribute(ATTRIBUTE_WATER)
		and c:IsType(TYPE_XYZ)
		and c:IsCanBeXyzMaterial(xyzc)
end


function s.xyzcheck(g)
	return g:GetClassCount(Card.GetRank)==1
end

-- ==================== ①  ====================


function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end


function s.thfilter(c)
	return aux.IsCodeListed(c,94380860) and c:IsAbleToHand()
end


function s.has_th_target(tp)
	return Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.thfilter),
		tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
end

-- ①
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return s.has_th_target(tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end

-- ① 
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	if not s.has_th_target(tp) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),
		tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

-- ==================== ② ====================


function s.atkfilter(c)
	return c:IsFaceup() and c:GetAttack()~=c:GetBaseAttack()
end


function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
		or Duel.IsExistingMatchingCard(s.atkfilter,tp,0,LOCATION_MZONE,1,nil)
end


function s.can_detach(c,tp)
	return c:CheckRemoveOverlayCard(tp,1,REASON_COST)
end


function s.spfilter(c,e,tp)
	return c:IsLocation(LOCATION_EXTRA)
		and (c:IsCode(20785975) or c:IsCode(94380860))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end


function s.has_sp_target(tp,e)
	return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
end


function s.matfilter(c)
	return c:IsCanOverlay()
end


function s.has_mat_target(tp)
	return Duel.IsExistingMatchingCard(s.matfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
end

-- ==================== ② ====================

-- ② 
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return s.can_detach(c,tp)
	end
	c:RemoveOverlayCard(tp,1,1,REASON_COST)
end

-- ② 
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return s.has_sp_target(tp,e)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

-- ② 
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end


	if not s.has_sp_target(tp,e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
	if not sc then return end

	sc:SetMaterial(nil)
	if Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)>0 then
		sc:CompleteProcedure()

  
		if s.has_mat_target(tp) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
			local mg=Duel.SelectMatchingCard(tp,s.matfilter,
				tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
			if #mg>0 then
				Duel.Overlay(sc,mg)
			end
		end
	end
end