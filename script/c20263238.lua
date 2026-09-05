-- 光天使 圣盾 (ID: 20263238)
local s,id,o=GetID()
local SET_STAR_SERAPH=0x86 -- 「光天使」官方字段代码
local EFFECT_DOUBLE_XMATERIAL=EFFECT_DOUBLE_XMATERIAL or 511001225

function s.initial_effect(c)
	-- ①：以场上1只「光天使」怪兽为对象：回手，自身手卡特召，本回合受到的效果伤害变为0 (HOPT: id)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg1)
	e1:SetOperation(s.spop1)
	c:RegisterEffect(e1)

	-- ②：召唤·特召成功的场合：从卡组特召1只「光天使 圣盾」以外的「光天使」怪兽，本回合只能从额外特召超量怪兽 (HOPT: id+o*100)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,id+o*100)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
	local e2_sp=e2:Clone()
	e2_sp:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2_sp)

	-- ③：作为3只以上素材的光属性超量怪兽超量召唤的素材的场合，这张卡可以作为2只数量的超量素材
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_DOUBLE_XMATERIAL)
	e3:SetTarget(s.xyztg)
	e3:SetValue(s.xyzval)
	c:RegisterEffect(e3)
end

-- ==================== ① 效果：弹场上「光天使」怪兽回手特召自身 + 效果伤害为0 ====================
function s.thfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(SET_STAR_SERAPH) and c:IsAbleToHand()
		and Duel.GetMZoneCount(tp,c,tp)>0
end

function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.thfilter(chkc,tp) end
	local c=e:GetHandler()
	if chk==0 then
		return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
			and Duel.IsExistingTarget(s.thfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end

function s.damval(e,re,val,r,rp,rc)
	if (r&REASON_EFFECT)~=0 then return 0 end
	return val
end

function s.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND+LOCATION_EXTRA) then
		if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
			-- 这个回合，自己受到的效果伤害变为0
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_CHANGE_DAMAGE)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetTargetRange(1,0)
			e1:SetValue(s.damval)
			e1:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e1,tp)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
			Duel.RegisterEffect(e2,tp)
		end
	end
end

-- ==================== ② 效果：卡组特召非同名「光天使」怪兽 + 额外超量自肃 ====================
function s.spfilter2(c,e,tp)
	return c:IsSetCard(SET_STAR_SERAPH) and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_DECK,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end

function s.splimit_xyz(e,c,sump,sumtype,sumpos,target_p,se)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_XYZ)
end

function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 这个回合，自己不是超量怪兽不能从额外卡组特殊召唤
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit_xyz)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end

-- ==================== ③ 效果：作为2只数量超量素材（光属性3体以上超量） ====================
function s.xyztg(e,c)
	return c:IsAttribute(ATTRIBUTE_LIGHT)
end

function s.xyzval(e,c)
	return 2
end