-- 天蚀炎蛾 (ID: 23600072)
local s,id,o=GetID()
local SET_ECLIPSE = 0xd92

function s.initial_effect(c)
	-- 注意：主卡组通常效果怪兽严禁调用 EnableReviveLimit()

	-- 注册全局召唤·特殊召唤活动计数器（分别使用 id 与 id+1，杜绝计数器被覆盖冲毁）
	Duel.AddCustomActivityCounter(id,ACTIVITY_SUMMON,s.counterfilter)
	Duel.AddCustomActivityCounter(id+1,ACTIVITY_SPSUMMON,s.counterfilter)

	-- ①：这张卡在手卡存在，以自己的墓地·除外状态的1只昆虫族·光属性怪兽为对象才能发动。
	-- 那只怪兽和这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	-- 彻底剔除不存在的 CATEGORY_GRAVE_SPSUMMON，使用原生宏规避算术报错
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id) -- ①效果独立 HOPT
	e1:SetCost(s.oathcost)
	e1:SetTarget(s.sptg1)
	e1:SetOperation(s.spop1)
	c:RegisterEffect(e1)

	-- ②：这张卡被送去墓地·除外状态的场合才能发动。
	-- 自己的墓地·除外状态的1只昆虫族·光属性怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id+o*100) -- ②效果独立 HOPT（防撞车规范 id+o*100）
	e2:SetCost(s.oathcost)
	e2:SetTarget(s.thtg2)
	e2:SetOperation(s.thop2)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e3)
end

-- ==================== 全局自肃计数与誓约 Cost ====================
function s.counterfilter(c)
	return c:IsRace(RACE_INSECT)
end

function s.splimit(e,c,sump,sumtype,sumpos,target_p,se)
	return not c:IsRace(RACE_INSECT)
end

function s.oathcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 独立核验两个互不干扰的计数器
		return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SUMMON)==0
			and Duel.GetCustomActivityCount(id+1,tp,ACTIVITY_SPSUMMON)==0
	end
	local c=e:GetHandler()
	-- 基础誓约：这些效果发动的回合，自己不是昆虫族怪兽不能召唤·特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	Duel.RegisterEffect(e2,tp)

	-- 客户端当回合自肃提示
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetReset(RESET_PHASE+PHASE_END)
	e3:SetTargetRange(1,0)
	Duel.RegisterEffect(e3,tp)
end

-- ==================== ① 效果：手卡发动特召两体 ====================
function s.spfilter1(c,e,tp)
	return (not c:IsLocation(LOCATION_REMOVED) or c:IsFaceup())
		and c:IsRace(RACE_INSECT) and c:IsAttribute(ATTRIBUTE_LIGHT)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local loc=LOCATION_GRAVE+LOCATION_REMOVED
	if chkc then return chkc:IsLocation(loc) and chkc:IsControler(tp) and s.spfilter1(chkc,e,tp) end
	if chk==0 then
		-- 使用原生卡号 59822133 彻底消除 CARD_BLUEEYES_SPIRIT 的 nil 崩溃风险
		return not Duel.IsPlayerAffectedByEffect(tp,59822133)
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>=2
			and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
			and Duel.IsExistingTarget(s.spfilter1,tp,loc,0,1,nil,e,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter1,tp,loc,0,1,1,nil,e,tp)
	g:AddCard(c)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,2,0,0)
end

function s.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or not tc or not tc:IsRelateToEffect(e) then return end
	if Duel.IsPlayerAffectedByEffect(tp,59822133) or Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	if not c:IsCanBeSpecialSummoned(e,0,tp,false,false) or not tc:IsCanBeSpecialSummoned(e,0,tp,false,false) then return end
	local g=Group.FromCards(c,tc)
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end

-- ==================== ② 效果：送墓/除外回收资源 ====================
function s.thfilter2(c)
	return (not c:IsLocation(LOCATION_REMOVED) or c:IsFaceup())
		and c:IsRace(RACE_INSECT) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToHand()
end

function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local loc=LOCATION_GRAVE+LOCATION_REMOVED
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter2,tp,loc,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,loc)
end

function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	local loc=LOCATION_GRAVE+LOCATION_REMOVED
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter2),tp,loc,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end