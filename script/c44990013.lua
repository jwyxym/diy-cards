--拉法姆和迦拉克隆
local s,id=GetID()
function s.initial_effect(c)
	c:SetSPSummonOnce(id)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(aux.FALSE)
	c:RegisterEffect(e0)

	-- 融合召唤手续
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(s.fuscon)
	e1:SetTarget(s.fustg)
	e1:SetOperation(s.fusop)
	e1:SetValue(SUMMON_TYPE_FUSION)
	c:RegisterEffect(e1)

	-- 自身手续：墓地·除外3张拉法姆回卡组
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	e2:SetValue(SUMMON_TYPE_SPECIAL+1)
	c:RegisterEffect(e2)

	-- ① 检索
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(function(e) return Duel.GetFlagEffect(e:GetHandlerPlayer(),id+300)==0 end)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)

	-- ② 卡组特召拉法姆怪兽并追加召唤
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(function(e) return Duel.GetFlagEffect(e:GetHandlerPlayer(),id+400)==0 end)
	e4:SetTarget(s.spxtg)
	e4:SetOperation(s.spxop)
	c:RegisterEffect(e4)
end

-- 融合素材条件（修正：必须是怪兽）
function s.fusfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
		and (c:IsSetCard(0x0cf0) or c:IsRace(RACE_DRAGON))
end

function s.fuscheck(g)
	if #g~=2 then return false end
	return g:IsExists(Card.IsSetCard,1,nil,0x0cf0) and g:IsExists(Card.IsRace,1,nil,RACE_DRAGON)
end

function s.fuscon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
	local g=Duel.GetMatchingGroup(s.fusfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil)
	return g:CheckSubGroup(s.fuscheck,2,2)
end

function s.fustg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Duel.GetMatchingGroup(s.fusfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local sg=g:SelectSubGroup(tp,s.fuscheck,true,2,2)
	if sg and #sg==2 then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	end
	return false
end

function s.fusop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g or #g~=2 then return end
	Duel.SendtoGrave(g,REASON_SPSUMMON)
	g:DeleteGroup()
end

-- 回3张手续
function s.spfilter(c)
	return c:IsSetCard(0x0cf0) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeckAsCost()
end

function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
	return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,3,nil)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local sg=g:SelectSubGroup(tp,aux.TRUE,true,3,3)
	if sg and #sg==3 then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	end
	return false
end

function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g or #g~=3 then return end
	Duel.SendtoDeck(g,tp,SEQ_DECKSHUFFLE,REASON_SPSUMMON)
	g:DeleteGroup()
end

-- ① 检索
function s.thfilter(c)
	return c:IsSetCard(0x0cf0) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
		Duel.RegisterFlagEffect(tp,id+300,RESET_PHASE+PHASE_END,0,1)
	end
end

-- ② 特召+追加召唤
function s.spxfilter(c,e,tp)
	return c:IsSetCard(0x0cf0) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sumfilter(c)
	return c:IsSetCard(0x0cf0) and c:IsSummonable(true,nil)
end
function s.spxtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spxfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spxop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spxfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local sg=Duel.GetMatchingGroup(s.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil)
		if #sg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
			local sc=sg:Select(tp,1,1,nil):GetFirst()
			Duel.Summon(tp,sc,true,nil)
		end
		Duel.RegisterFlagEffect(tp,id+400,RESET_PHASE+PHASE_END,0,1)
	end
end