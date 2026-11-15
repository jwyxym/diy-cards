-- 业簇之枪-亚弗姆·扎
local s,id,o=GetID()
local SET_YE_CU=0x97f          -- 「业簇」字段
local SET_CRYSTAL_FLOWER=0x68f -- 「水晶花」字段
local CARD_DINATO_TUNA=44400046 -- 「狄娜托·图娜」

function s.initial_effect(c)
	aux.AddCodeList(c,CARD_DINATO_TUNA)

	-- 装备魔法卡规则限制
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EFFECT_EQUIP_LIMIT)
	e0:SetValue(1)
	c:RegisterEffect(e0)

	-- ①：以自己墓地１只「狄娜托·图娜」为对象才能发动。那只怪兽特殊召唤并把这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target1)
	e1:SetOperation(s.operation1)
	c:RegisterEffect(e1)

	-- ②-1：１回合１次，以对方魔法·陷阱区域１张卡为对象，那张卡里侧表示除外。
	local e2a=Effect.CreateEffect(c)
	e2a:SetDescription(aux.Stringid(id,1))
	e2a:SetCategory(CATEGORY_REMOVE)
	e2a:SetType(EFFECT_TYPE_IGNITION)
	e2a:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2a:SetRange(LOCATION_MZONE)
	e2a:SetCountLimit(1)
	e2a:SetTarget(s.rmtg)
	e2a:SetOperation(s.rmop)

	local e2grant=Effect.CreateEffect(c)
	e2grant:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e2grant:SetRange(LOCATION_SZONE)
	e2grant:SetTargetRange(LOCATION_MZONE,0)
	e2grant:SetTarget(s.eftg)
	e2grant:SetLabelObject(e2a)
	c:RegisterEffect(e2grant)

	-- ②-2：这张卡不会被除外
	local e2b=Effect.CreateEffect(c)
	e2b:SetType(EFFECT_TYPE_EQUIP)
	e2b:SetCode(EFFECT_CANNOT_REMOVE)
	e2b:SetCondition(s.gaincon)
	c:RegisterEffect(e2b)

	-- ③：这张卡从卡组以外送去墓地的场合才能发动。选卡组１张「水晶花」·「业簇」卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,id+o*100)
	e3:SetCondition(s.thcon3)
	e3:SetTarget(s.thtg3)
	e3:SetOperation(s.thop3)
	c:RegisterEffect(e3)
end

--------------------------------------------------------------------------------
-- ①效果：苏生墓地「狄娜托·图娜」并装备
--------------------------------------------------------------------------------
function s.spfilter1(c,e,tp)
	return c:IsCode(CARD_DINATO_TUNA) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.target1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter1(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(s.spfilter1,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter1,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end

function s.operation1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
		if c:IsRelateToEffect(e) and not c:IsStatus(STATUS_LEAVE_CONFIRMED) then
			Duel.Equip(tp,c,tc)
		end
	end
end

--------------------------------------------------------------------------------
-- ②效果：装备「狄娜托·图娜」时的获得效果（里侧除外对方魔陷 ＋ 无法除外抗性）
--------------------------------------------------------------------------------
function s.eftg(e,c)
	return c==e:GetHandler():GetEquipTarget() and c:IsCode(CARD_DINATO_TUNA)
end

function s.gaincon(e)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and ec:IsCode(CARD_DINATO_TUNA)
end

function s.rmfilter(c)
	return c:IsAbleToRemove(POS_FACEDOWN)
end

function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(1-tp) and s.rmfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.rmfilter,tp,0,LOCATION_SZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,s.rmfilter,tp,0,LOCATION_SZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end

function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.Remove(tc,POS_FACEDOWN,REASON_EFFECT)
	end
end

--------------------------------------------------------------------------------
-- ③效果：从卡组以外送墓检索「水晶花」·「业簇」卡
--------------------------------------------------------------------------------
function s.thcon3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return not c:IsPreviousLocation(LOCATION_DECK)
end

function s.thfilter3(c)
	return (c:IsSetCard(SET_CRYSTAL_FLOWER) or c:IsSetCard(SET_YE_CU)) and c:IsAbleToHand()
end

function s.thtg3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter3,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.thop3(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter3,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end